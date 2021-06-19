## AZADI SoC
For the SKY130, an SoC design was created for the Google-sponsored Open MPW shuttles.
## Getting Started 
Start by cloning the repo and uncompressing the files.

git clone <https://github.com/efabless/caravel.git>
cd caravel
make uncompress
Then you need to install the open_pdks prerequisite:

Magic VLSI Layout Tool is needed to run open_pdks -- version >= 8.3.60*
* Note: You can avoid the need for the magic prerequisite by using the openlane docker to do the installation step in open_pdks. This could be done by cloning openlane and following the instructions given there to use the Makefile.

Install the required version of the PDK by running the following commands:

export PDK_ROOT=<The place where you want to install the pdk>
make pdk
Then, you can learn more about the caravel chip by watching these video:

Caravel User Project Features -- <https://youtu.be/zJhnmilXGPo>
Aboard Caravel -- How to put your design on Caravel? -- <https://youtu.be/9QV8SDelURk>
Things to Clarify About Caravel -- What versions to use with Caravel? -- <https://youtu.be/-LZ522mxXMw>
You could only use openlane:rc6
Make sure you have the commit hashes provided here inside the <Makefile>
