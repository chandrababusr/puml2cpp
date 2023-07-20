#! /usr/bin/python3

test_dir = "./pumls"

contents = [
    "@startuml@enduml",
    "@startuml @enduml",
    "@startumlproj@enduml",
    "@startuml proj@enduml",
    "@startumlproj @enduml",
    "@startuml proj @enduml",
    "@startuml\n@enduml",
    "@startumlproj\n@enduml",
    "@startuml proj\n@enduml",
    "@startuml proj \n@enduml",
]

test_n = 0
for content in contents:
    test_n += 1
    filename = f"{test_dir}/test_{test_n:03d}.wsd"
    with open(filename, "w") as testfile:
        testfile.write(content)
