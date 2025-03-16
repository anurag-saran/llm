
#!/usr/bin/env python
import os
import sys
from llama_stack import LlamaStackAsLibraryClient

# Print Python path for debugging
print(f"Using Python from: {sys.executable}")

# Set environment variables
INFERENCE_MODEL = "meta-llama/Llama-3.2-3B-Instruct"
os.environ["INFERENCE_MODEL"] = INFERENCE_MODEL

# Create clients with increased timeout
def create_library_clients(template="ollama"):
    inference_client = LlamaStackAsLibraryClient(
        template,
        config={
            "request_timeout": 120,
            "provider_request_timeout": 120,
            "server": {"port": 5001}
        }
    )
    inference_client.initialize()
    
    safety_client = LlamaStackAsLibraryClient(
        template,
        config={
            "request_timeout": 120,
            "provider_request_timeout": 120,
            "server": {"port": 5002}
        }
    )
    safety_client.initialize()
    
    return inference_client, safety_client

inference_client, safety_client = create_library_clients()

# Run inference
message = [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "Write a haiku about coding"},
]

# Use separate clients for inference and safety checks
safety_response = safety_client.safety.check(message)
if safety_response.is_safe:
    inference_response = inference_client.inference.chat_completion(
        model_id=INFERENCE_MODEL,
        messages=message
    )
    print(inference_response.completion_message.content)
else:
    print("The message contains unsafe content.")
