#%%
import pandas as pd
import numpy as np
import tensorflow as tf
from keras.models import Sequential
from keras.layers import LSTM, Dense, Dropout, BatchNormalization
from keras.callbacks import EarlyStopping

# Load data from CSV or Excel
rawdata = pd.read_csv('data.csv')

data = rawdata.iloc[:, 1:]

# Function to create sequences of 10 elements with the target as the 10th element
def create_sequences(data, sequence_length=9):
    sequences = []
    for i in range(len(data) - sequence_length + 1): 
        sequence = data[i:i+sequence_length] 
        input_seq = sequence[:-1]  
        target = sequence[-1] 
        sequences.append((input_seq, target)) 
    return np.array(sequences)

df = pd.DataFrame(data) 

# Ensure the data is in float32 format
data = df.values.astype('float32')

# Create sequences and targets
sequences = create_sequences(data)

X_train = np.array([seq[0] for seq in sequences])
y_train = np.array([seq[1] for seq in sequences])

num_features = X_train.shape[2] 

# Build the model
model = Sequential([
    LSTM(units=128, input_shape=(X_train.shape[1], num_features)),
    Dense(units=128, activation='relu'),
    BatchNormalization(),
    Dense(units=64, activation='relu'),
    BatchNormalization(),
    Dense(units=32, activation='relu'),
    Dropout(0.25),
    Dense(units=16, activation='relu'),
    Dense(units=1)
])

model.summary()

early_stopping = EarlyStopping(patience=15, monitor='acc', mode='max', restore_best_weights=True)

# Convert to TensorFlow tensors
X_train_tensor = tf.convert_to_tensor(X_train, dtype="float32")
y_train_tensor = tf.convert_to_tensor(y_train, dtype="float32")

# Create a TensorFlow dataset
dataset = tf.data.Dataset.from_tensor_slices((X_train_tensor, y_train_tensor)).batch(16)

for exp in dataset.take(1):
    for v in exp:
        print(v)

# Compile and train the model
model.compile(
    optimizer='adam', 
    loss='mean_squared_error', 
    metrics=['acc'],
    )
model.fit(dataset, epochs=100, callbacks=[early_stopping])

model.evaluate(dataset)
#%%