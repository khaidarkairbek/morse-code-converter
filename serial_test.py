import serial
import time

def send_data(serial_port, baud_rate, data):
    try:
        # Open serial port
        ser = serial.Serial(serial_port, baud_rate )
        time.sleep(2)  # Wait for the serial connection to initialize

        # Send data
        if isinstance(data, str):
            ser.write(data.encode())  # Send string data
        elif isinstance(data, bytes):
            ser.write(data)  # Send byte data
        else:
            print("Data type not supported. Use str or bytes.")

        # Close serial port
        ser.close()

        print(f"Data '{data}' sent successfully to {serial_port} at {baud_rate} baud.")

    except serial.SerialException as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    # Example usage
    serial_port = "COM1"  # Replace with your serial port
    baud_rate = 9600
    data = "KHAIDAR COLLIN PLAY BALL"  # Replace with your data

    send_data(serial_port, baud_rate, data)
