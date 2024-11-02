import Control  # Import the compiled Cython module
import time
import threading
import pigpio

class ControlHandler:
    """
    This class acts as a wrapper around the Control class from the compiled Cython module.
    It initializes the thrusters and starts the control threads.
    """

    def __init__(self, thruster_pins):
        self.control = Control.Control(*thruster_pins)  # Initialize the Control object
        self.control_thread = threading.Thread(target=self.run_control)
        self.gui_thread = threading.Thread(target=self.gui_control)

    def start(self):
        #Start the control and GUI threads
        self.control_thread.start()
        self.gui_thread.start()

    def run_control(self):
        """Run the main control loop using the Cython module."""
        try:
            print("Starting Control Loop...")
            Control.run(self.control)  # Call the `run` function from the Cython module
        except KeyboardInterrupt:
            print("Control loop interrupted.")

    def gui_control(self):
        """Run the GUI communication loop using the Cython module."""
        try:
            print("Starting GUI Loop...")
            Control.GUI(self.control)  # Call the `GUI` function from the Cython module
        except KeyboardInterrupt:
            print("GUI loop interrupted.")
"""
    #Stop the control loop
    def stop(self):
        print("Stopping Control...")
        self.control_thread.join()
        self.gui_thread.join()
"""

if __name__ == "__main__":
    # Define GPIO pins for the thrusters
    thruster_pins = [9, 11, 16, 8]  # Replace with your actual pins

    # Initialize the control handler
    control_handler = ControlHandler(thruster_pins)

    # Start the control and GUI threads
    control_handler.start()
