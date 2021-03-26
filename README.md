# Custom-16-Bit-CPU
E2E design and implementation of 16-bit Harvard-architecture CPU using VHDL. Please see the PPT for a TLDR of the project, and the PDF report for a full explanation of the CPU and its functionality. The CPU is Turning-complete; example supported commands:
- LDI (immediate load)
- ADD (add 2 values, write to register)
- STORE (write register value to memory)
- LOAD (read from memory to register)
- BRZ (conditional branch)
- JMP (jump back to a previous instruction)

This was a labor of love, and I learned a ton in the process. 

Example computation

<img width="704" alt="Screen Shot 2021-03-25 at 10 51 09 PM" src="https://user-images.githubusercontent.com/9117105/112588438-a108ab00-8dbc-11eb-8d87-7d2d6f71af1b.png">

CPU Diagram

<img width="669" alt="Screen Shot 2021-03-25 at 10 42 00 PM" src="https://user-images.githubusercontent.com/9117105/112587746-63575280-8dbb-11eb-8046-40eca36321eb.png">
