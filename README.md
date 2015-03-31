# GPUOpenCV

Sample repository for experimenting with hunter to combine multiple packages (in this case OpenCV and GPUImage)

Hunter will check pacakges in this order:

see: https://github.com/hunter-packages/gate) 

test cmake variable HUNTER_ROOT (control, shared downloads and builds)
test environment variable HUNTER_ROOT (recommended: control, shared downloads and builds)
test directory ${HOME}/HunterPackages (shared downloads and builds)
test directory ${PROGRAMFILES}/HunterPackages (shared downloads and builds, windows only)
test directory HunterPackages in current project sources (not recommended: no share, local downloads and builds)