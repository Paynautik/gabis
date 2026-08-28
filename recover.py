import json

filepath = "/Users/raphaelgab-momoh/.gemini/antigravity/brain/13b53fa4-ead6-421d-8831-33d876290ba1/.system_generated/logs/transcript_full.jsonl"

with open(filepath, 'r') as f:
    for line in f:
        data = json.loads(line)
        if "tool_calls" in data:
            for tc in data["tool_calls"]:
                if tc["name"] == "write_to_file" or tc["name"] == "replace_file_content":
                    args = tc["args"]
                    if "TargetFile" in args and "home_screen.dart" in args["TargetFile"]:
                        if "CodeContent" in args:
                            print(f"Found CodeContent write of length {len(args['CodeContent'])}")
                            with open("recovered_home_screen.dart", "w") as out:
                                out.write(args["CodeContent"])
