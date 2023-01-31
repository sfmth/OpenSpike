<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Thanks again! Now go create something AMAZING! :D
***
***
***
*** To avoid retyping too much info. Do a search and replace for the following:
*** github_username, repo_name, twitter_handle, email, project_title, project_description
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->

<!-- PROJECT LOGO -->
  <h1 align="center">The Opensource Verilog Workbench</h1>

  <p align="center">
    A Verilog workbench with opensource toolchains that lets you write and simulate your verilog code with ease
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project
This project aims to ease the setup of your verilog projects by providing you with a precoded workbench.
![image](https://user-images.githubusercontent.com/23662796/178709130-ad64a100-0d17-45ab-8561-e9ab9b15baac.png)

### Built With

* `Icarus Verilog (iverilog)` To simulate your verilog code
* `Cocotb` To verify your verilog code by writing python testbenches
* `GTKWave` To view the input or outpot waveforms of your design 
* `Yosys` To synthesize your design into actual hardware and view it



<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

For the project to work you would have to install these things first:

* [Icarus Verilog](https://steveicarus.github.io/iverilog/usage/installation.html)
* [Cocotb](https://docs.cocotb.org/en/stable/install.html)
* [GTKWave](http://gtkwave.sourceforge.net/)
* [Yosys](https://yosyshq.net/yosys/download.html)

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/sfmth/verilog-workbench/ && cd verilog-workbench
   ```




<!-- USAGE EXAMPLES -->
## Usage
To run a simulation, first you would have to write your verilog code and testbench. You can put your Verilog code in `verilog-workbench/src/` and your test bench in `verilog-workbench/test`. Each verilog file should include only a single module and also the name of the file has to be the same as the module name. For cocotb python test benches it is mandatory to add `test_` to the beginning of the module name and use it as the file name for the corresponding module. There is also a need to add a dump code snippet to the end of your module, you can find it in src/encoder.v.


Then, in order to run the simulation you can do:
```sh
make gtkwave NAM=<module name> SINGLE=<True / False>
```

And if you want to see your synthesized design you can do:
```sh
make show_synth_png NAM=<module name>
```
Or for a more detailed gate level synthesize you can run the following:
```sh
make show_synth_full_svg NAM=<module name>
```


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.





