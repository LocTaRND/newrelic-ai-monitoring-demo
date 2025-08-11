# app.py
import os
import openai
from flask import Flask, request, jsonify
import newrelic.agent

# Initialize New Relic
newrelic.agent.initialize()

app = Flask(__name__)
openai.api_key = os.getenv('OPENAI_API_KEY')

@newrelic.agent.function_trace()
@app.route('/chat', methods=['POST'])
def chat():
    try:
        user_message = request.json.get('message')
        
        # OpenAI API call - automatically instrumented by New Relic
        response = openai.ChatCompletion.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": user_message}
            ],
            max_tokens=150
        )
        
        return jsonify({
            'response': response.choices[0].message.content,
            'model': response.model,
            'tokens_used': response.usage.total_tokens
        })
    except Exception as e:
        newrelic.agent.record_exception()
        return jsonify({'error': str(e)}), 500

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
