import subprocess
class LinuxCommandSender:
    def __init__(self):
        pass
    def execute_command(self, command):
        try:
            result = subprocess.run(command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
            return result.stdout
        except subprocess.CalledProcessError as e:
            return f"Error executing command : {e}"
command_sender= LinuxCommandSender()
output = command_sender.execute_command("rmdir Miha")
print(output)