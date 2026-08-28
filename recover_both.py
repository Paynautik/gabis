import json

filepath = "/Users/raphaelgab-momoh/.gemini/antigravity/brain/13b53fa4-ead6-421d-8831-33d876290ba1/.system_generated/logs/transcript_full.jsonl"

screen_content = None
shell_content = None

with open(filepath, 'r') as f:
    for line in f:
        data = json.loads(line)
        if "tool_calls" in data:
            for tc in data["tool_calls"]:
                if tc["name"] in ["replace_file_content", "write_to_file"]:
                    args = tc["args"]
                    if "TargetFile" in args:
                        if "home_screen.dart" in args["TargetFile"] and "CodeContent" in args:
                            screen_content = args["CodeContent"]
                        elif "home_shell.dart" in args["TargetFile"] and "CodeContent" in args:
                            shell_content = args["CodeContent"]

if screen_content:
    with open("lib/features/home/home_screen.dart", "w") as out:
        out.write(screen_content)
    print("Recovered home_screen.dart")

if shell_content:
    with open("lib/features/home/home_shell.dart", "w") as out:
        out.write(shell_content)
    print("Recovered home_shell.dart")
