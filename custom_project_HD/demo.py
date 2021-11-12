# import the necessary packages
from imutils.video import VideoStream								# To access camera
from tensorflow.keras.preprocessing.image import img_to_array		# To convert frames to arrays
from tensorflow.keras.models import load_model						# To load the trained model
import numpy as np
import argparse
import imutils														# For utility functions
import pickle
import time
import cv2															# OpenCV library
import os

# Load the face detector model
def get_face_detector_model(folder_dir):
	proto_file = "deploy.prototxt"
	model_file = "res10_300x300_ssd_iter_140000.caffemodel"
	face_proto = os.path.join(folder_dir, proto_file)
	face_model = os.path.join(folder_dir, model_file)
	return cv2.dnn.readNetFromCaffe(face_proto, face_model)

def get_liveness_detection_model():
	model = load_model("./model.h5")
	return model

def get_label_encoder():
	lable_encoder = open("./label_encoder.pickle", "rb")
	return pickle.loads(lable_encoder.read())

def get_face_detection(frame, face_detector):
	blob = cv2.dnn.blobFromImage(cv2.resize(frame, (300, 300)), 1.0,
		(300, 300), (104.0, 177.0, 123.0))
	face_detector.setInput(blob)
	return face_detector.forward()

def get_face_coordinates(detections, frame_w, frame_h, detection_idx):
	boundary = detections[0, 0, detection_idx, 3:7] * np.array([frame_w, frame_h, frame_w, frame_h])
	(top_left_x, top_left_y, bottom_right_x, bottom_right_y) = boundary.astype("int")
	top_left_x = max(0, top_left_x)
	top_left_y = max(0, top_left_y)
	bottom_right_x = min(frame_w, bottom_right_x)
	bottom_right_y = min(frame_h, bottom_right_y)
	return (top_left_x, top_left_y, bottom_right_x, bottom_right_y)

def liveness_detection(frame, top_left_x, top_left_y, bottom_right_x, bottom_right_y, model, lable_encoder):
	face_region = frame[top_left_y:bottom_right_y, top_left_x:bottom_right_x]
	data_dimension = (32, 32)   # 32x32 pixels, to be consistent with training data
	data = cv2.resize(face_region, data_dimension)

	# Scale the pixels down to [0,1]
	scale_factor = 255.0
	data = data.astype("float")/scale_factor

	# Convert data to array
	data = img_to_array(data)
	data = np.expand_dims(data, axis=0)

	# Get liveness detection on the processed data
	preds = model.predict(data)[0]
	idx = np.argmax(preds)
	label = lable_encoder.classes_[idx]
	probability = preds[idx]

	return label, probability

def draw_bounding_box(frame, label, probability, top_left_x, top_left_y, bottom_right_x, bottom_right_y):
	label = "{}: {:.3f}".format(label, probability)
	cv2.putText(frame, label, (top_left_x, top_left_y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2)
	cv2.rectangle(frame, (top_left_x, top_left_y), (bottom_right_x, bottom_right_y), (0, 0, 255), 2)
	cv2.imshow("Frame", frame)

def main():
	# Start streaming
	vs = VideoStream(src=0).start()
	time.sleep(2.0)

	# Get face detector model and liveness detection model
	face_detector_model = get_face_detector_model("./face_detector")
	liveness_detection_model = get_liveness_detection_model()
	lable_encoder = get_label_encoder()

	while True:
		frame = vs.read()
		frame = imutils.resize(frame, width=600)
		(h, w) = frame.shape[:2]

		# Get face detection from the frame
		detections = get_face_detection(frame, face_detector_model)
		
		# loop over the detections
		for i in range(0, detections.shape[2]):		
			confidence = detections[0, 0, i, 2]		# Prediction probability

			# Filter out weak predictions
			if confidence > 0.5:
				(top_left_x, top_left_y, bottom_right_x, bottom_right_y) = get_face_coordinates(detections, w, h, i)
				
				# Extract the face ROI and determine whether the face is real or fake
				liveness_label, probability = liveness_detection(frame, top_left_x, top_left_y, bottom_right_x, 
																 bottom_right_y, liveness_detection_model, lable_encoder)

				# Draw bounding box on the frame
				draw_bounding_box(frame, liveness_label, probability, top_left_x, top_left_y, bottom_right_x, bottom_right_y)

		# The program stops if "e" is pressed
		key = cv2.waitKey(1) & 0xFF
		if key == ord("e"):
			break

	cv2.destroyAllWindows()
	vs.stop()

main()