import math
import wave
import struct
import random
import os

def generate_river_sound(filename, duration_sec=3, sample_rate=44100):
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        # Simple white noise filter to simulate a river flow
        for i in range(int(sample_rate * duration_sec)):
            # Generate noise
            value = random.randint(-15000, 15000)
            # Apply a simple low-pass filter effect by smoothing
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)

def generate_hornbill_sound(filename, duration_sec=2, sample_rate=44100):
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        # Frequency sweep for bird call
        for i in range(int(sample_rate * duration_sec)):
            t = float(i) / sample_rate
            # Create a pulsing, sweeping sine wave
            freq = 800 + 400 * math.sin(2 * math.pi * 5 * t)
            value = int(10000 * math.sin(2 * math.pi * freq * t) * math.exp(-t))
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)

def generate_dhol_sound(filename, duration_sec=2, sample_rate=44100):
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        # Rhythmic low frequency thumps
        for i in range(int(sample_rate * duration_sec)):
            t = float(i) / sample_rate
            # 2 beats per second
            beat_env = math.exp(-10 * (t % 0.5))
            value = int(20000 * math.sin(2 * math.pi * 100 * t) * beat_env)
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)

os.makedirs('assets/audio', exist_ok=True)
generate_river_sound('assets/audio/brahmaputra_river.wav')
generate_hornbill_sound('assets/audio/hornbill_call.wav')
generate_dhol_sound('assets/audio/bihu_dhol.wav')
print("Audio generation complete.")
