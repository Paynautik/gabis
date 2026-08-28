import json

filepath = "/Users/raphaelgab-momoh/.gemini/antigravity/brain/13b53fa4-ead6-421d-8831-33d876290ba1/.system_generated/logs/transcript_full.jsonl"

found_content = None
with open(filepath, 'r') as f:
    for line in f:
        data = json.loads(line)
        if "tool_calls" in data:
            for tc in data["tool_calls"]:
                if tc["name"] == "replace_file_content" or tc["name"] == "write_to_file":
                    args = tc["args"]
                    if "TargetFile" in args and "home_screen.dart" in args["TargetFile"]:
                        if "CodeContent" in args:
                            found_content = args["CodeContent"]

if found_content:
    with open("lib/features/home/home_screen.dart", "w") as out:
        out.write(found_content)
    print("Recovered home_screen.dart from write_to_file")
else:
    print("Not found in write_to_file, looking for last read...")
