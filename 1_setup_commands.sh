# Create new conda environment
conda create -n stack-client python=3.10
conda init $(basename $SHELL)
source ~/.zshrc  # if using zsh
conda activate stack-client

# Install required packages
pip install uv
uv pip install llama-stack
pip install llama-stack-client