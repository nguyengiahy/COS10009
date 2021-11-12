# import the necessary packages
from tensorflow.keras.models import Sequential				# To initialise the sequential model
from tensorflow.keras.layers import Flatten					# To unroll the output from conv + pooling layer
from tensorflow.keras.layers import Activation 				# To get the activation functions
from tensorflow.keras.layers import Dense 					# To get the dense layer
from tensorflow.keras.layers import BatchNormalization 		# To standardize the inputs to a layer in neural network
from tensorflow.keras.layers import MaxPooling2D 			# To get pooling layer - max pooling
from tensorflow.keras import backend as K 					
from tensorflow.keras.layers import Conv2D 					# To get convolution layer
from tensorflow.keras.layers import Dropout 				# To get dropout probability - prevent overfitting

# The convolutional neural network structure
class LivenessNet:
	@staticmethod
	def build(width, height, depth, classes):
		''' Parameters:
		- width: how wide the image is
		- height: how tall the image is
		- depth: the number of channels for the image (e.g., RGB images have 3 channels)
		- classes: the number of classes (2 in our case: real/fake faces)
		'''

		''' 
		Initialize the model with a Sequential network
		'''
		model = Sequential()
		conv_kernel_size = (3,3)		# Dimension of convolution kernel
		pool_kernel_size = (2,2)		# Dimension of pooling kernel
		dropout_prob = 0.25 			# Dropout probability

		# convolution layer 1: conv(activation ReLU) ->  conv(activation ReLU) -> pooling(max pooling)
		# conv kernel: 3x3
		model.add(Conv2D(16, conv_kernel_size, input_shape=(height, width, depth), padding="same"))
		model.add(Activation("relu"))
		model.add(BatchNormalization(axis=-1))
		model.add(Conv2D(16, conv_kernel_size, padding="same"))
		model.add(Activation("relu"))
		model.add(BatchNormalization(axis=-1))
		model.add(MaxPooling2D(pool_size=pool_kernel_size))			# Pooling kernel: 2x2
		model.add(Dropout(dropout_prob))							# Dropout probability

		# convolution layer 2: conv(activation ReLU) ->  conv(activation ReLU) -> pooling(max pooling)
		# conv kernel: 3x3
		model.add(Conv2D(32, conv_kernel_size, padding="same"))
		model.add(Activation("relu"))
		model.add(BatchNormalization(axis=-1))
		model.add(Conv2D(32, conv_kernel_size, padding="same"))
		model.add(Activation("relu"))
		model.add(BatchNormalization(axis=-1))
		model.add(MaxPooling2D(pool_size=pool_kernel_size))			# Pooling kernel: 2x2
		model.add(Dropout(dropout_prob))							# Dropout probability

		# Fully Connected layer: activation ReLU
		model.add(Flatten())
		model.add(Dense(64))
		model.add(Activation("relu"))
		model.add(BatchNormalization())
		model.add(Dropout(2*dropout_prob))							# Dropout probability

		# softmax classifier
		model.add(Dense(classes))
		model.add(Activation("softmax"))

		return model