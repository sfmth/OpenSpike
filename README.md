# OpenSpike
OpenSpike a spiking neural network (SNN) accelerator made using fully open-source EDA tools, process design kit (PDK), and memory macros synthesized using [OpenRAM](https://openram.org/). The chip is taped out in the 130 nm SkyWater process and integrates over 1 million synaptic weights, and offers a reprogrammable architecture. It operates at a clock speed of 40 MHz, a supply of 1.8 V, uses a PicoRV32 core for control, and occupies an area of 33.3 mm^2. The throughput of the accelerator is 48,262 images per second with a wallclock time of 20.72 μs, at 56.8 GOPS/W. The spiking neurons use hysteresis to provide an adaptive threshold (i.e., a Schmitt trigger) which can reduce state instability. This results in high performing SNNs across a range of benchmarks that remain competitive with state-of-the- art, full precision SNNs.


<p align="center" float="center">
  <img src="docs/system-small.jpg" width="500"/>
</p>

## Citation
If you find OpenSpike useful in your work, please cite the following source:

```
@software{modaresi2023openspike,
  title        = {OpenSpike: An OpenRAM SNN Accelerator}
  author       = {Modaresi, Farhad and Guthaus, Matthew and Eshraghian, Jason K},
  journal      = {2023 IEEE International Symposium on Circuits and Systems},
  year         = {2023}
}
```

## Timings
<p align="center" float="center">
  <img src="docs/control-unit.png.png" width="300"/>
</p>

## OpenSpike Core's Layout
Design area 3mm X 3mm (9 mm^2).
<p align="center" float="center">
  <img src="docs/chip.jpg" width="300"/>
</p>

## 2KB 1RW-1R 32x512 SRAM Layout
<p align="center" float="center">
  <img src="docs/sram-2k.jpg" width="300"/>
</p>
