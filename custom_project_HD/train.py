!unzip dataset.zip

# import the necessary packages
import matplotlib                                       # To generate training plot
import matplotlib.pyplot as plt                         # Generate training plot
import pickle                                           # Serialize our label encoder to disk
import os
import numpy as np                                      
import cv2
from tensorflow.keras.preprocessing.image import ImageDataGenerator   # For data augmentation, provide us with batches of randomly mutated images
from sklearn.model_selection import train_test_split    # Splits the data for training & testing
from tensorflow.keras.optimizers import Adam            # Adam optimizer
from imutils import paths                               # Help to gather paths to all the image files on disk 
from sklearn.metrics import classification_report       # Generate statistical report of model's performance
from sklearn.preprocessing import LabelEncoder
from tensorflow.keras.utils import to_categorical       
from livenessnet import LivenessNet                     # The LivenessNet CNN

# convert images to a NumPy array, and scale the pixels down to [0,1]
def scale_down(images):
    scale_factor = 255.0
    processed_images = np.array(images, dtype="float")/scale_factor
    return processed_images

# Get images and corresponding labels from the dataset
def process_data_and_label():
    imageDirs = list(paths.list_images("dataset"))
    images = []
    labels = []

    for imageDir in imageDirs:
        image = cv2.imread(imageDir)                # Read the image into variable
        image = cv2.resize(image, (32, 32))         # Resize the image to be 32x32
        label = imageDir.split(os.path.sep)[-2]     # Extract the label

        # Add the processed image and label to the list
        images.append(image)
        labels.append(label)

    # Check the processed data and labels 
    print(len(labels))
    print(len(images))
    print(labels)

    return images, labels

# Encode the labels
def encode_label(labels):
    class_num = 2         # We have only 2 classes
    label_encoder = LabelEncoder()
    encoded_label = label_encoder.fit_transform(labels)
    encoded_label = to_categorical(encoded_label, class_num)

    return encoded_label, label_encoder

# Data augmentation: generate images with random rotations, shifts, ...
def augmentation():
    rotate = 20
    zoom = 0.15
    shift = 0.2
    shear = 0.15
    augmentation = ImageDataGenerator(shear_range=shear, rotation_range=rotate, 
                                      height_shift_range=shift, fill_mode="nearest",
                                      zoom_range=zoom, width_shift_range=shift, horizontal_flip=True)
    return augmentation

# Splits the data into 75% for training and 25% for testing
def split_data(images, labels):
    test_split_portion = 0.25
    (train_data, test_data, train_label, test_label) = train_test_split(images, labels, test_size=test_split_portion)

    return (train_data, test_data, train_label, test_label)

def main():
    # Initialise training parameters
    batch_size = 8
    learning_rate = 1e-4
    epochs = 50

    # Preprocessing
    data, labels = process_data_and_label()
    label_encoder = get_label_encoder()
    labels, label_encoder = encode_label(labels)
    data = scale_down(data)
    train_data, test_data, train_label, test_label = split_data(data, labels)
    aug = augmentation()

    # Initialise and compile the model
    # Adam optimizer
    optimizer = Adam(learning_rate=learning_rate, decay=learning_rate/epochs)
    # RGB images (3 channels) with dimesion 32x32 pixels. Two classes
    model = LivenessNet.build(width=32, height=32, depth=3, classes=len(label_encoder.classes_))
    # Compile the model:
    # - optimizer: Adam
    # - loss function: binary cross entropy
    model.compile(optimizer=optimizer, loss="binary_crossentropy", metrics=["accuracy"])

    # Train model
    H = model.fit(x=aug.flow(train_data, train_label, batch_size=batch_size), 
                  steps_per_epoch=len(train_data)//batch_size, validation_data=(test_data, test_label), epochs=epochs)

    # Export the trained model
    model.save("model.h5")

main()