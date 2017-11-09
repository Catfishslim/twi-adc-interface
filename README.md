# twi-adc-interface

EGRE 365 Digital Systems
Final Design Project – I2C (TWI) Analog-to-Digital Converter Interface
This project should be completed in groups of two and each group should turn in
one design project report.
For this project you will implement an FPGA design for the Digilent Nexys4 DDR board
that interfaces an external Analog-to-Digital Converter (ADC) to the FPGA. The ADC
is an Analog Devices AD7991, 12-bit converter with four independent analog input
channels. The AD7991 communicates via an I2C bus, but the protocol is compatible
with the open-source TWI bus, so that will be utilized for communications. The TWI
communications are based on a TWI IP core developed by Digilent, Inc. and distributed
as part of their reference designs for the Nexys4 board. The AD7991 will be configured
to perform a single conversion of the analog voltage on the VIN0 input for each
communications request. The user-designed hardware in the FPGA should request a
conversion operation 20 times each second (i.e., at 20 Hz) and display the resulting 12-
bit digital voltage measurement via the methods described below.
The ADC project should be implemented in four phases. Upon completion, each phase
should be demonstrated to the instructor or TA and signed off on the accompanying
signoff sheet. The completed signoff sheet must be included in the final project report.
There is a 2% penalty per phase, for not completing each individual phase by the
required due date and a 5% penalty per phase, for not completing and having each
individual phase signed off.
