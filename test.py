def example(   
    arg1,  # <-- Try jumping from here (1)
    arg2    # <-- Or here (2)
):
    data = { 
        "key": [  # <-- Nested pair (3)
            "value"
        ]
    }
    print(  # <-- Multi-line call (4)
        "Hello", 
        "World"
    )

# Test cases:
# 1. Place cursor inside `arg1` → <M-e> jumps to `):` line
# 2. Place cursor inside `"value"` → <M-e> jumps to `]` then `}`
# 3. <M-a> always returns to the opening pair


x = [ 1 , 2 ,3, "123" ]
y = {1 ,2 ,3 }
