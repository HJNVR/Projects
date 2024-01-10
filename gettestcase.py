import re
from llm import gpt35,gpt4
import json
from getprompt import get_prompt
systemprompt = '''
you are a helpful assistent generate test cases in specific format for given task .
you will receive some code complete task in such format:
```python
import ...(the packages)
#some functions predefined herec
def PREDEFINED_FUNCTION_NAME():
    """THE_FUNCTION_REFERENCE"""
    #some code
...
#the up ward function is completed you don't need complete , the next is to complete
def THE_FUNCTION_NAME():
    """THE_FUNCTION_REFERENCE"""
    #TODO
```
but you won't do this part of work , user will do this part later , you only need give back test cases for user to check him self.
you simply give back testcases in such json format:
{{
    "testcases":int
    "assert lines":[
        "assert f(input)==output,'testcases 1'",
        ...
    ]
}}'''
usertemplete = '''please give me the test cases , here is the original task
```python
{demo_code}
```
'''
assistenettemplete = '''
sure , here is my reply :
```python
{demo_json}
```
'''
templete = '''
from the reference of the functions in the file i will give you , you can get the functions , and there demo input expect out put :
for example , if i give you this file:
```python
{demo_code}
```
you should reply this json:
```python
{demo_json}
```
please based on this code give me your json reply :
```python
{input_code}
```
===
assistent: 
sure, here is my reply :
```python
'''
demo_json = """
{"testcases":2,"assert lines":["assert has_close_elements([1.0, 2.0, 3.0], 0.5)==False,'test case 1'","assert has_close_elements([1.0, 2.8, 3.0, 4.0, 5.0, 2.0], 0.3)==True,'test case 2'"]}
"""
demo_code = '''
from typing import List
def has_close_elements(numbers: List[float], threshold: float) -> bool:
    """ Check if in given list of numbers, are any two numbers closer to each other than
    given threshold.
    >>> has_close_elements([1.0, 2.0, 3.0], 0.5)
    False
    >>> has_close_elements([1.0, 2.8, 3.0, 4.0, 5.0, 2.0], 0.3)
    True
    """
'''

m1 = {"role":"system","content":systemprompt}
m2 = {"role":"user","content":usertemplete.format(demo_code = demo_code)}
m3 = {"role":"assistant","content":assistenettemplete.format(demo_json = demo_json)}
rootmessages = [m1,m2,m3]

def parse_json_block(string):
    # define a regular expression pattern that matches the code block grammar
    pattern = r"{(.*)}"
    # use re.search to find the first match of the pattern in the string
    match = re.search(pattern, string, flags=re.DOTALL)
    # if there is a match, extract the code from the match object
    if match:
        code = match.group(0)
        # return a dictionary with the key "code" and the value as the code
        return json.loads(code)
    # if there is no match, return None
    else:
        return None

def get_test_case(inputcode):
    messages = rootmessages
    messages.append({
        "role":"user",
        "content":usertemplete.format(demo_code = inputcode)
    })
    out = gpt35(messages)
    return parse_json_block(out[0]['content'])

if __name__=='__main__':
    input_code = get_prompt(32)
    print(input_code)
    print(get_test_case(input_code))