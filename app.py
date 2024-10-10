from flask import Flask, jsonify, request
import cv2
import numpy as np

app = Flask(__name__)

# Renk tespiti yapacak fonksiyon
def detect_colors():
    # Kameradan görüntü alma
    webcam = cv2.VideoCapture(0)
    _, imageFrame = webcam.read()

    # Görüntüyü BGR'den HSV'ye dönüştürme
    hsvFrame = cv2.cvtColor(imageFrame, cv2.COLOR_BGR2HSV)

    # Renk aralıkları
    colors = {
        "Yellow": ([20, 100, 100], [30, 255, 255]),
        "Red": ([136, 87, 111], [180, 255, 255]),
        "Green": ([25, 52, 72], [102, 255, 255]),
        "Blue": ([94, 80, 2], [120, 255, 255])
    }

    detected_colors = []

    for color_name, (lower, upper) in colors.items():
        lower_bound = np.array(lower, np.uint8)
        upper_bound = np.array(upper, np.uint8)
        mask = cv2.inRange(hsvFrame, lower_bound, upper_bound)
        if cv2.countNonZero(mask) > 0:
            detected_colors.append(color_name)

    webcam.release()
    return detected_colors

@app.route('/detect', methods=['GET'])
def detect():
    colors = detect_colors()
    return jsonify(colors=colors)

if __name__ == '__main__':
    app.run(debug=True)
