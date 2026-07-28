# AHB to APB Bridge — AMBA Protocol RTL Implementation

![Language](https://img.shields.io/badge/Language-Verilog-blue)
![Tool](https://img.shields.io/badge/Tool-Xilinx%20Vivado-orange)
![Protocol](https://img.shields.io/badge/Protocol-AMBA%20AHB%20%2F%20APB-green)
![Status](https://img.shields.io/badge/Status-In%20Progress-yellow)

A fully synthesizable RTL implementation of an AMBA AHB-to-APB 
bridge in Verilog. Designed to interface a high-bandwidth AHB 
master with low-power APB peripherals.

> Files and documentation being added progressively.


---

## The Problem

Modern SoCs use multiple bus standards simultaneously. The CPU 
runs on AHB — fast, pipelined, high bandwidth. Peripherals like 
UART, GPIO, and SPI run on APB — simple, low-power, two-cycle 
handshake. They cannot communicate directly. This bridge 
translates between them.

---

## AHB Slave Interface (`ahb_slave_interface.v`)

AHB is pipelined — the address of transfer N arrives one clock 
cycle before the data of transfer N. APB needs both simultaneously.

This module resolves the mismatch using a 2-stage pipeline:

haddr  ──► [haddr1]  ──► [haddr2]  ──► APB

hwdata ──► [hwdata1] ──► [hwdata2] ──► APB

hwrite ──► [hwritereg] ──► [hwritereg1] ──► APB




Also generates:
- `valid` — confirms a real transfer is occurring
- `tempselx` — one-hot peripheral select decoded from address

### Address Map

| Slave | Address Range | `tempselx` |
|---|---|---|
| Slave 1 | `0x8000_0000` – `0x83FF_FFFF` | `3'b001` |
| Slave 2 | `0x8400_0000` – `0x87FF_FFFF` | `3'b010` |
| Slave 3 | `0x8800_0000` – `0x8BFF_FFFF` | `3'b100` |




---

## APB Controller (`apb_controller.v`)

An 8-state Mealy FSM that drives the APB two-phase handshake:

- **SETUP phase**: `psel=1`, `penable=0`
- **ENABLE phase**: `psel=1`, `penable=1` ← transfer happens here

Also drives `hreadyout` low to stall the AHB master while 
the slower APB transfer completes.

### FSM States

| State | Encoding | Description |
|---|---|---|
| `idle` | 000 | Waiting for valid transfer |
| `read` | 001 | APB setup cycle for read |
| `renable` | 010 | APB enable cycle for read |
| `wwait` | 011 | Capture write address and data |
| `write` | 100 | APB setup cycle for write |
| `wenable` | 101 | APB enable cycle for write |
| `writep` | 110 | Pipelined write setup (burst) |
| `wenablep` | 111 | Pipelined write enable (burst) |


---

## APB Interface (`apb_interface.v`)

Drives the final APB output signals to the peripheral and 
generates read data for simulation. When a read transfer is 
active (pwrite=0, penable=1, psel active), it returns a 
random value simulating a peripheral response.

| Signal | Direction | Description |
|---|---|---|
| `pwrite` | input | Write control from controller |
| `penable` | input | Enable signal from controller |
| `psel` | input | Peripheral select from controller |
| `paddr` | input | Address to peripheral |
| `pwdata` | input | Write data to peripheral |
| `prdata` | output | Read data returned to bridge |






























