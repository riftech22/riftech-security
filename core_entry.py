#!/usr/bin/env python3
"""
RIFTECH SECURITY SYSTEM
"""

import sys
import os

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
os.environ['OPENCV_VIDEOIO_MSMF_ENABLE_HW_TRANSFORMS'] = '0'

from PyQt6.QtWidgets import QApplication


def check_gpu() -> bool:
    try:
        import torch
        if torch.cuda.is_available():
            print(f"\033[92m[OK] GPU ACCELERATED: {torch.cuda.get_device_name(0)}\033[0m")
            return True
        print("\033[93m[CPU] NO GPU DETECTED\033[0m")
        return False
    except ImportError:
        print("\033[93m[CPU] PYTORCH NOT AVAILABLE\033[0m")
        return False


def check_dependencies():
    print("\n" + "="*60)
    print("\033[92m██████╗ ██╗   ██╗ ██████╗███████╗██╗  ██╗███████╗██████╗ ██████╗ ██████╗ ██████╗ ███████╗\033[0m")
    print("\033[92m██╔══██╗██║   ██║██╔════╝██╔════╝██║ ██╔╝██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔════╝\033[0m")
    print("\033[92m███████╔╝██║   ██║██║     █████╗  █████╔╝ █████╗  ██████╔╝██║  ███╗██████╔╝████╗ ████╗█████╗  \033[0m")
    print("\033[92m██╔══██╗██║   ██║██║     ██╔══╝  ██╔══██╗██╔══╝  ██╔══██╗██║   ██║██╔══██╗██╔══██╗██╔══╝  \033[0m")
    print("\033[92m██║  ██║╚██████╔╝╚██████╗███████╗██║  ██╗███████╗██████╔╝╚██████╔╝██████╔╝██║     ███████╗\033[0m")
    print("\033[92m╚═╝  ╚═╝ ╚═════╝  ╚═════╝╚══════╝╚═╝  ╚═╝╚══════╝╚═════╝  ╚═════╝ ╚═════╝ ╚═╝     ╚══════╝\033[0m")
    print("="*60 + "\n")
    
    print("\033[96m[SYSTEM] CHECKING DEPENDENCIES...\033[0m\n")
    
    try:
        from ultralytics import YOLO
        print("\033[92m[OK] YOLOv8 DETECTOR\033[0m - Object detection ready")
    except ImportError:
        print("\033[93m[MISS] YOLOv8\033[0m - Install: pip install ultralytics")
    
    try:
        import face_recognition
        print("\033[92m[OK] FACE RECOGNITION\033[0m - Trusted person identification ready")
    except ImportError:
        print("\033[93m[OPT] FACE RECOGNITION\033[0m - Optional feature (pip install face_recognition)")
    
    try:
        import mediapipe
        print("\033[92m[OK] MEDIAPIPE\033[0m - Skeleton tracking ready")
    except ImportError:
        print("\033[93m[OPT] MEDIAPIPE\033[0m - Optional feature (pip install mediapipe)")
    
    print("\n" + "\033[96m[SYSTEM] HARDWARE CHECK...\033[0m")
    print("")
    has_gpu = check_gpu()
    print("\n" + "="*60 + "\n")
    return has_gpu


def main():
    has_gpu = check_dependencies()
    
    print("\033[96m[SYSTEM] STARTING RIFTECH SECURITY...\033[0m\n")
    
    try:
        from interface_display import SecuritySystemWindow
        
        app = QApplication(sys.argv)
        app.setApplicationName("RIFTECH SECURITY")
        
        window = SecuritySystemWindow(has_gpu=has_gpu)
        window.show()
        
        print("\033[92m[SUCCESS] RIFTECH SECURITY STARTED\033[0m\n")
        
        sys.exit(app.exec())
    except Exception as e:
        print(f"\033[91m[ERROR] {str(e)}\033[0m")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
