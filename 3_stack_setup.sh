# Build the stack

# 1. First create the environment
conda create -n llama-stack python=3.10 -y

# 2. Activate the environment
conda activate llama-stack

# 3. Install latest llama-stack
pip install llama-stack

# 4. Then build the stack
llama stack build --template ollama --image-type conda

# 5. Check if Ollama server is running
if ! curl -s --head http://localhost:11434 > /dev/null; then
    echo "Error: Ollama server is not running. Please start it with 'ollama serve' in another terminal."
    exit 1
fi

# 6. Check if required model is available
if ! ollama list | grep -q "llama3.2:3b-instruct-fp16"; then
    echo "Model llama3.2:3b-instruct-fp16 not found. Pulling model..."
    ollama pull llama3.2:3b-instruct-fp16
    if [ $? -ne 0 ]; then
        echo "Error: Failed to pull model"
        exit 1
    fi
fi

# 7. Run the stack
llama stack run ./run-inference.yaml \
    --port 5001 \
    --env INFERENCE_MODEL=meta-llama/Llama-3.2-3B-Instruct \
    --env OLLAMA_URL=http://localhost:11434

echo "Testing inference model..."
curl -X POST http://localhost:5001/v1/inference/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model_id": "meta-llama/Llama-3.2-3B-Instruct",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "Write a haiku about programming"}
    ]
  }'

echo -e "\n\nTesting safety model..."
curl -X POST http://localhost:5001/v1/safety/check \
  -H "Content-Type: application/json" \
  -d '{
    "model_id": "meta-llama/Llama-Guard-3-1B",
    "messages": [
      {"role": "user", "content": "Tell me about gardening"}
    ]
  }'

# Test Ollama inference model directly
curl -X POST http://localhost:11434/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3.2:3b-instruct-fp16",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "Write a haiku about programming"}
    ]
  }'

# Test Ollama safety model directly
curl -X POST http://localhost:11434/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama-guard3:1b",
    "messages": [
      {"role": "user", "content": "Tell me about gardening"}
    ]
  }'