import os

db_beta_url = "https://wiscomsbeta.matematicasuperpiatta.it"
db_release_url = "https://wiscoms.matematicasuperpiatta.it"
api_release = 'fvqyugucy1.execute-api.eu-south-1.amazonaws.com/release'
api_dev = 'fvqyugucy1.execute-api.eu-south-1.amazonaws.com/dev'

entries_api = ('release', 'dev')
entries_operating_system = ('linux', 'mac', 'ios', 'windows', 'android')
entries_dev_phase = ('beta', 'release')
entries_server_type = ('local', 'multi', 'ecs')
entries_debug = ('true', 'false')
entries_monitor = ('true', 'false')
entries_slack = ('true', 'false')

class Configuration:
    def __init__(self):
        self.project_root = "."

        ########## EDIT ##########
        self.version = '1.2.0'
        self.api = 'release'
        self.os = 'windows'
        self.dev_phase = 'release'
        self.server_type = 'ecs'
        self.debug = 'false'
        self.monitor = 'false'
        self.slack = 'false'
        self.android_code = '73'
        ##########################
    
    def update_all(self):
        self.update_version()
        self.update_api()
        self.update_os()
        self.update_dev_phase()
        self.update_server_type()
        self.update_debug()
        self.update_monitor()
        self.update_slack()
        self.update_android_code()
    
    def print(self):
        print("Ready for release!\n")
        print("Current configuration:")
        print(f"- version: {self.version}")
        print(f"- api: {self.api}")
        print(f"- os: {self.os}")
        print(f"- dev_phase: {self.dev_phase}")
        print(f"- server_type: {self.server_type}")
        print(f"- debug: {self.debug}")
        print(f"- monitor: {self.monitor}")
        print(f"- slack: {self.slack}")
        print(f"- android code: {self.android_code}")
        
    @staticmethod
    def read_file(path):
        with open(path, "r") as f:
            lines = f.readlines()
            return lines
    
    @staticmethod
    def write_file(path, lines):
        with open(path, "w") as f:
            for line in lines:
                f.write(line)


    def update_version(self):
        if len(self.version.split('.')) != 3:
            print("Cannot update version. Format not valid: " + self.version)
        major, minor, patch = self.version.split('.')
        
        path = os.path.join(self.project_root, "builtin/ms-mainmenu/oop/handshake.lua")
        lines = Configuration.read_file(path)
        for i, line in enumerate(lines):
            if 'version =' in line:
                pre, _ = line.split("=")
                lines[i] = pre + '= "' + self.version + '",\n'
        Configuration.write_file(path, lines)
        
        path = os.path.join(self.project_root, "CMakeLists.txt")
        lines = Configuration.read_file(path)
        for i, line in enumerate(lines):
            if 'set(VERSION_MAJOR ' in line:
                lines[i] = 'set(VERSION_MAJOR ' + major + ')\n'
            if 'set(VERSION_MINOR ' in line:
                lines[i] = 'set(VERSION_MINOR ' + minor + ')\n'
            if 'set(VERSION_PATCH ' in line:
                lines[i] = 'set(VERSION_PATCH ' + patch + ')\n'
        Configuration.write_file(path, lines)

        path = os.path.join(self.project_root, "android/build.gradle")
        lines = Configuration.read_file(path)
        for i, line in enumerate(lines):
            if 'project.ext.set("versionMajor", ' in line:
                lines[i] = 'project.ext.set("versionMajor", ' + major + ')\n'
            if 'project.ext.set("versionMinor", ' in line:
                lines[i] = 'project.ext.set("versionMinor", ' + minor + ')\n'
            if 'project.ext.set("versionPatch", ' in line:
                lines[i] = 'project.ext.set("versionPatch", ' + patch + ')\n'
        Configuration.write_file(path, lines)
        
        path = os.path.join(self.project_root, "snapcraft.yaml")
        lines = Configuration.read_file(path)
        for i, line in enumerate(lines):
            if "version:" in line:
                lines[i] = "version: " + self.version + "\n"
        Configuration.write_file(path, lines)


    def update_api(self):
        if self.api not in entries_api:
            print("Cannot update api. Value not valid: " + self.api)
        
        path = os.path.join(self.project_root, "minetest.conf")
        lines = Configuration.read_file(path)
        for i, line in enumerate(lines):
            if len(line) >= 14 and line[:14] == 'ms_discovery =':
                pre, _ = line.split("=")
                post = api_dev if self.api == "dev" else api_release
                lines[i] = pre + '= ' + post + '\n'
        Configuration.write_file(path, lines)
    

    def update_os(self):
        if self.os not in entries_operating_system:
            print("Cannot update os. Value not valid: " + self.os)
        
        path = os.path.join(self.project_root, "builtin/ms-mainmenu/init.lua")
        lines = Configuration.read_file(path)
        for i, line in enumerate(lines):
            if 'global_os =' in line:
                pre, _ = line.split("=")
                lines[i] = pre + '= "' + self.os + '",\n'
        Configuration.write_file(path, lines)

        path = os.path.join(self.project_root, "minetest.conf")
        lines = Configuration.read_file(path)
        for i, line in enumerate(lines):
            if 'debug_log_level =' in line:
                dl = 0 if self.os == 'linux' else 3
                lines[i] = "debug_log_level = " + str(dl) + "\n"
        Configuration.write_file(path, lines)
    
    def update_dev_phase(self):
        if self.dev_phase not in entries_dev_phase:
            print("Cannot update dev_phase. Value not valid: " + self.dev_phase)

        path = os.path.join(self.project_root, "builtin/ms-mainmenu/oop/handshake.lua")
        lines = Configuration.read_file(path)
        for i, line in enumerate(lines):
            if 'dev_phase =' in line:
                pre, post = line.split("=")
                lines[i] = pre + '= "' + self.dev_phase + '",\n'
        Configuration.write_file(path, lines)

        path = os.path.join(self.project_root, "builtin/ms-mainmenu/init.lua")
        lines = Configuration.read_file(path)
        for i, line in enumerate(lines):
            if 'matematicasuperpiatta.it/wiscom' in line:
                pre, post = line.split("/wiscoms")
                if self.dev_phase == "beta":
                    ok = post.startswith("beta")
                    lines[i] = line if ok else pre + "/wiscomsbeta" + post
                elif self.dev_phase == "release":
                    ok = not post.startswith("beta")
                    lines[i] = line if ok else pre + "/wiscoms" + post[4:]
        Configuration.write_file(path, lines)

        path = os.path.join(self.project_root, "minetest.conf")
        lines = Configuration.read_file(path)
        for i, line in enumerate(lines):
            if 'matematicasuperpiatta.it/wiscom' in line:
                pre, post = line.split("/wiscoms")
                if self.dev_phase == "beta":
                    ok = post.startswith("beta")
                    lines[i] = line if ok else pre + "/wiscomsbeta" + post
                elif self.dev_phase == "release":
                    ok = not post.startswith("beta")
                    lines[i] = line if ok else pre + "/wiscoms" + post[4:]
        Configuration.write_file(path, lines)
    

    def update_server_type(self):
        if self.server_type not in entries_server_type:
            print("Cannot update server_type. Value not valid: " + self.server_type)
        
        path = os.path.join(self.project_root, "builtin/ms-mainmenu/oop/handshake.lua")
        lines = Configuration.read_file(path)
        for i, line in enumerate(lines):
            if 'server_type =' in line:
                pre, _ = line.split("=")
                lines[i] = pre + '= "' + self.server_type + '",\n'
        Configuration.write_file(path, lines)
    

    def update_debug(self):
        if self.debug not in entries_debug:
            print("Cannot update debug. Value not valid: " + self.debug)
        
        path = os.path.join(self.project_root, "builtin/ms-mainmenu/oop/handshake.lua")
        lines = Configuration.read_file(path)
        for i, line in enumerate(lines):
            if 'debug =' in line and not "--" in line:
                pre, _ = line.split("=")
                lines[i] = pre + '= "' + self.debug + '",\n'
        Configuration.write_file(path, lines)

    def update_monitor(self):
        if self.monitor not in entries_monitor:
            print("Cannot update monitor. Value not valid: " + self.monitor)

        path = os.path.join(self.project_root, "builtin/ms-mainmenu/oop/handshake.lua")
        lines = Configuration.read_file(path)
        for i, line in enumerate(lines):
            if 'monitor =' in line:
                pre, post = line.split("=")
                lines[i] = pre + '= "' + self.monitor + '",\n'
        Configuration.write_file(path, lines)


    def update_slack(self):
        if self.slack not in entries_slack:
            print("Cannot update slack. Value not valid: " + self.slack)
        
        path = os.path.join(self.project_root, "builtin/ms-mainmenu/oop/handshake.lua")
        lines = Configuration.read_file(path)
        for i, line in enumerate(lines):
            if 'slack =' in line:
                pre, post = line.split("=")
                lines[i] = pre + '= "' + self.slack + '",\n'
        Configuration.write_file(path, lines)

    def update_android_code(self):
        path = os.path.join(self.project_root, "android/build.gradle")
        lines = Configuration.read_file(path)
        for i, line in enumerate(lines):
            if 'project.ext.set("versionCode", ' in line:
                lines[i] = 'project.ext.set("versionCode", ' + self.android_code + ')\n'
        Configuration.write_file(path, lines)

if __name__ == "__main__":
    config = Configuration()
    config.update_all()
    config.print()
    
