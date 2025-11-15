import subprocess
import sys
import os
import argparse
import time
import shutil

def read_sb3(stdout):
	for line in stdout:
		print(line, flush=True)
	stdout.close()

def main():
	parser = argparse.ArgumentParser(allow_abbrev = False)
	parser.add_argument('--name', type = str)
	parser.add_argument('--port', type = int)
	parser.add_argument('--store_temp', action='store_true')

	args = parser.parse_args()

	if args.store_temp:
		if not args.name:
			print('--name is required when --store_temp is set')
			return

	temp_training_name = 'test_one_shot'
	one_shot = False
	if args.name is None:
		one_shot = True
		agent_training_name = temp_training_name
	else:
		agent_training_name = args.name

	training_file_name = agent_training_name + '.zip'
	training_onnx_file_name = agent_training_name + '.onnx'
	agent_status_log_path = agent_training_name + '_tf_logs'

	if args.store_temp:
		if os.path.exists(training_file_name):
			print(f'training exists {training_file_name}')
			return
		if os.path.exists(agent_status_log_path):
			print(f'agent status log exists {agent_status_log_path}')
			return

		temp_training_file_name = temp_training_name + '.zip'
		temp_training_onnx_file_name = temp_training_name + '.onnx'
		temp_agent_status_log_path = temp_training_name + '_tf_logs'
		if os.path.exists(temp_training_file_name):
			shutil.copyfile(temp_training_file_name, training_file_name)
		if os.path.exists(temp_training_onnx_file_name):
			shutil.copyfile(temp_training_onnx_file_name, training_onnx_file_name)
		if os.path.exists(temp_agent_status_log_path):
			shutil.copytree(temp_agent_status_log_path, agent_status_log_path)
		print(f'copied temp training to {agent_training_name}')
		return

	if one_shot:
		if os.path.exists(training_file_name):
			os.remove(training_file_name)
		if os.path.exists(agent_status_log_path):
			shutil.rmtree(agent_status_log_path)

	print(f'start agent_status, log dir = {agent_status_log_path}')
	proc_status = subprocess.Popen(
		[sys.executable, 'agent_status.py', '--path', agent_status_log_path],
		text = True,
		bufsize = 1)

	sb3_params = [
		'--save_model_path', agent_training_name,
		'--onnx_export_path', agent_training_name,
		'--linear_lr_schedule']
	if os.path.exists(training_file_name):
		sb3_params = sb3_params + ['--resume_model_path', agent_training_name]

	print(f'start sb3, training name: {agent_training_name}')
	proc_sb3 = subprocess.Popen(
		[sys.executable, 'stable_baselines3_example.py'] + sb3_params,
		text = True,
		bufsize = 1)

	try:
		while True:
			time.sleep(1)
	except KeyboardInterrupt:
		pass

if __name__ == '__main__':
	main()
