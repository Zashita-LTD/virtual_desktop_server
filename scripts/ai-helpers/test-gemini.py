#!/usr/bin/env python3
"""
Test script for Gemini API.

Usage:
    export GOOGLE_API_KEY="your-api-key"
    python3 scripts/ai-helpers/test-gemini.py

Get API key from: https://makersuite.google.com/app/apikey

Requirements:
    - google-generativeai installed
    - GOOGLE_API_KEY environment variable set
"""

import google.generativeai as genai
import os
import sys

def check_api_key():
    """Check if API key is configured"""
    print("\n" + "="*60)
    print("Checking API Key")
    print("="*60)
    
    api_key = os.environ.get('GOOGLE_API_KEY')
    if not api_key:
        print("❌ GOOGLE_API_KEY environment variable not set\n")
        print("To set API key:")
        print("  export GOOGLE_API_KEY='your-api-key-here'")
        print("\nGet your API key from:")
        print("  https://makersuite.google.com/app/apikey")
        return False
    
    # Obscure the key for display
    obscured_key = api_key[:8] + "..." + api_key[-4:]
    print(f"✅ API key found: {obscured_key}\n")
    return True

def test_text_generation():
    """Test basic text generation"""
    print("\n" + "="*60)
    print("Testing: Text Generation")
    print("="*60)
    
    try:
        genai.configure(api_key=os.environ['GOOGLE_API_KEY'])
        model = genai.GenerativeModel('gemini-pro')
        
        prompt = "Say hello in 3 different languages (short response)"
        print(f"Prompt: {prompt}")
        print("\nGenerating...")
        
        response = model.generate_content(prompt)
        
        print("✅ Text generation successful")
        print(f"\nResponse:\n{response.text}\n")
        return True
    except Exception as e:
        print(f"❌ Text generation failed: {e}\n")
        return False

def test_chat():
    """Test chat functionality"""
    print("\n" + "="*60)
    print("Testing: Chat")
    print("="*60)
    
    try:
        genai.configure(api_key=os.environ['GOOGLE_API_KEY'])
        model = genai.GenerativeModel('gemini-pro')
        chat = model.start_chat(history=[])
        
        # First message
        print("User: What is 2+2?")
        response = chat.send_message("What is 2+2?")
        print(f"Gemini: {response.text}")
        
        # Follow-up message
        print("\nUser: What about 3+3?")
        response = chat.send_message("What about 3+3?")
        print(f"Gemini: {response.text}")
        
        print("\n✅ Chat test successful\n")
        return True
    except Exception as e:
        print(f"❌ Chat test failed: {e}\n")
        return False

def test_streaming():
    """Test streaming responses"""
    print("\n" + "="*60)
    print("Testing: Streaming")
    print("="*60)
    
    try:
        genai.configure(api_key=os.environ['GOOGLE_API_KEY'])
        model = genai.GenerativeModel('gemini-pro')
        
        prompt = "Count from 1 to 5 with explanations"
        print(f"Prompt: {prompt}")
        print("\nStreaming response:")
        print("-" * 60)
        
        response = model.generate_content(prompt, stream=True)
        
        for chunk in response:
            print(chunk.text, end='', flush=True)
        
        print("\n" + "-" * 60)
        print("✅ Streaming test successful\n")
        return True
    except Exception as e:
        print(f"❌ Streaming test failed: {e}\n")
        return False

def test_code_generation():
    """Test code generation"""
    print("\n" + "="*60)
    print("Testing: Code Generation")
    print("="*60)
    
    try:
        genai.configure(api_key=os.environ['GOOGLE_API_KEY'])
        model = genai.GenerativeModel('gemini-pro')
        
        prompt = "Write a Python function to calculate fibonacci numbers. Keep it short."
        print(f"Prompt: {prompt}")
        print("\nGenerating...")
        
        response = model.generate_content(prompt)
        
        print("✅ Code generation successful")
        print(f"\nResponse:\n{response.text}\n")
        return True
    except Exception as e:
        print(f"❌ Code generation failed: {e}\n")
        return False

def test_safety_settings():
    """Test with custom safety settings"""
    print("\n" + "="*60)
    print("Testing: Safety Settings")
    print("="*60)
    
    try:
        from google.generativeai.types import HarmCategory, HarmBlockThreshold
        
        genai.configure(api_key=os.environ['GOOGLE_API_KEY'])
        model = genai.GenerativeModel('gemini-pro')
        
        safety_settings = {
            HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
            HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        }
        
        print("Testing with custom safety settings...")
        response = model.generate_content(
            "Tell me a safe joke",
            safety_settings=safety_settings
        )
        
        print("✅ Safety settings test successful")
        print(f"\nResponse:\n{response.text}\n")
        return True
    except Exception as e:
        print(f"❌ Safety settings test failed: {e}\n")
        return False

def main():
    print("\n" + "="*60)
    print(" Gemini API Test")
    print("="*60)
    print(f"Python Version: {sys.version.split()[0]}")
    
    # Check if library is installed
    try:
        import google.generativeai
        print(f"Gemini SDK installed: ✅")
    except ImportError:
        print("❌ google-generativeai not installed")
        print("\nInstall with:")
        print("  pip install google-generativeai")
        return 1
    
    # Check API key
    if not check_api_key():
        return 1
    
    tests = [
        ("Text Generation", test_text_generation),
        ("Chat", test_chat),
        ("Streaming", test_streaming),
        ("Code Generation", test_code_generation),
        ("Safety Settings", test_safety_settings),
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
    
    print(f"Tests passed: {passed}/{total}")
    
    if all(results):
        print("✅ Gemini API is working perfectly!")
        print("\nYou can now:")
        print("  - Generate text content")
        print("  - Have conversations with chat")
        print("  - Generate code")
        print("  - Process multimodal content (with gemini-pro-vision)")
        return 0
    elif passed > 0:
        print("⚠️  Some tests failed but API is accessible")
        return 1
    else:
        print("❌ All tests failed")
        print("\nPlease check:")
        print("  - API key is valid")
        print("  - API key has correct permissions")
        print("  - Internet connection is working")
        return 1

if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print("\n\nExiting...")
        sys.exit(1)
