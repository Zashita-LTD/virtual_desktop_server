#!/usr/bin/env python3
"""
Test script for Vertex AI connection and basic operations.

Usage:
    python3 scripts/ai-helpers/test-vertex-ai.py

Requirements:
    - google-cloud-aiplatform installed
    - Authenticated with Google Cloud (gcloud auth login or service account)
    - Project set (gcloud config set project PROJECT_ID)
"""

from google.cloud import aiplatform
import sys
import os

def test_initialization():
    """Test Vertex AI initialization"""
    print("\n" + "="*60)
    print("Testing: Vertex AI Initialization")
    print("="*60)
    
    try:
        # Try to get project from environment or gcloud config
        project = os.environ.get('GCP_PROJECT_ID', 'viktor-integration')
        location = os.environ.get('GCP_REGION', 'us-central1')
        
        print(f"Project: {project}")
        print(f"Location: {location}")
        
        aiplatform.init(
            project=project,
            location=location
        )
        print("✅ Vertex AI initialized successfully\n")
        return True
    except Exception as e:
        print(f"❌ Failed to initialize Vertex AI: {e}\n")
        print("Troubleshooting:")
        print("  1. Authenticate: gcloud auth application-default login")
        print("  2. Set project: gcloud config set project PROJECT_ID")
        print("  3. Enable API: gcloud services enable aiplatform.googleapis.com")
        return False

def test_list_models():
    """List available models"""
    print("\n" + "="*60)
    print("Testing: List Models")
    print("="*60)
    
    try:
        models = aiplatform.Model.list()
        print(f"✅ Found {len(models)} model(s)")
        
        if len(models) > 0:
            print("\nFirst 5 models:")
            for i, model in enumerate(models[:5]):
                print(f"  {i+1}. {model.display_name}")
        else:
            print("  (No custom models found - this is normal for new projects)")
        
        print()
        return True
    except Exception as e:
        print(f"❌ Failed to list models: {e}\n")
        return False

def test_text_generation():
    """Test text generation with PaLM 2"""
    print("\n" + "="*60)
    print("Testing: Text Generation (PaLM 2)")
    print("="*60)
    
    try:
        from vertexai.language_models import TextGenerationModel
        
        print("Loading text-bison model...")
        model = TextGenerationModel.from_pretrained("text-bison@002")
        
        print("Generating text...")
        response = model.predict(
            "Say hello in 3 different languages",
            max_output_tokens=100,
            temperature=0.7
        )
        
        print("✅ Text generation successful")
        print(f"\nResponse:\n{response.text}\n")
        return True
    except Exception as e:
        print(f"⚠️  Text generation test skipped or failed: {e}")
        print("Note: This is normal if you don't have access to PaLM 2 API\n")
        return False

def test_chat():
    """Test chat with PaLM 2"""
    print("\n" + "="*60)
    print("Testing: Chat (PaLM 2)")
    print("="*60)
    
    try:
        from vertexai.language_models import ChatModel
        
        print("Loading chat-bison model...")
        chat_model = ChatModel.from_pretrained("chat-bison@002")
        chat = chat_model.start_chat()
        
        print("Sending message...")
        response = chat.send_message("What is 2+2?")
        
        print("✅ Chat test successful")
        print(f"\nResponse:\n{response.text}\n")
        return True
    except Exception as e:
        print(f"⚠️  Chat test skipped or failed: {e}")
        print("Note: This is normal if you don't have access to PaLM 2 API\n")
        return False

def test_endpoints():
    """Test listing endpoints"""
    print("\n" + "="*60)
    print("Testing: List Endpoints")
    print("="*60)
    
    try:
        endpoints = aiplatform.Endpoint.list()
        print(f"✅ Found {len(endpoints)} endpoint(s)")
        
        if len(endpoints) > 0:
            print("\nEndpoints:")
            for endpoint in endpoints:
                print(f"  - {endpoint.display_name}")
        else:
            print("  (No endpoints found - this is normal for new projects)")
        
        print()
        return True
    except Exception as e:
        print(f"❌ Failed to list endpoints: {e}\n")
        return False

def main():
    print("\n" + "="*60)
    print(" Vertex AI Connection Test")
    print("="*60)
    print(f"Python Version: {sys.version.split()[0]}")
    
    # Check if library is installed
    try:
        import google.cloud.aiplatform as ai
        print(f"Vertex AI SDK Version: {ai.__version__}")
    except ImportError:
        print("❌ google-cloud-aiplatform not installed")
        print("\nInstall with:")
        print("  pip install google-cloud-aiplatform")
        return 1
    
    tests = [
        ("Initialization", test_initialization),
        ("List Models", test_list_models),
        ("List Endpoints", test_endpoints),
        ("Text Generation", test_text_generation),
        ("Chat", test_chat),
    ]
    
    results = []
    for name, test_func in tests:
        try:
            results.append(test_func())
        except KeyboardInterrupt:
            print("\n\nTest interrupted by user")
            return 1
        except Exception as e:
            print(f"\n❌ Unexpected error in {name}: {e}\n")
            results.append(False)
    
    # Summary
    print("\n" + "="*60)
    print(" Test Summary")
    print("="*60)
    
    passed = sum(results)
    total = len(results)
    critical_tests = results[:3]  # First 3 tests are critical
    
    print(f"Tests passed: {passed}/{total}")
    
    if all(critical_tests):
        print("✅ Vertex AI connection is working!")
        print("\nYou can now:")
        print("  - Train custom models")
        print("  - Deploy models to endpoints")
        print("  - Use pretrained models (if you have access)")
        return 0
    else:
        print("⚠️  Some critical tests failed")
        print("\nPlease check:")
        print("  - Authentication: gcloud auth application-default login")
        print("  - Project: gcloud config set project PROJECT_ID")
        print("  - APIs enabled: gcloud services list --enabled | grep aiplatform")
        return 1

if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print("\n\nExiting...")
        sys.exit(1)
