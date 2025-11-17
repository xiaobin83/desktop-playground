if [[ -f "$1.zip" ]]; then
	echo "resume training $1"
	python stable_baselines3_example.py --save_model_path=$1 --resume_model_path=$1 --onnx_export_path=$1
else
	echo "new training $1"
	python stable_baselines3_example.py --save_model_path=$1 --onnx_export_path=$1
fi
