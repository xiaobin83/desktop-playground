from torch.utils.tensorboard import SummaryWriter

class Viz:
	def __init__(self, path: str):
		self._writer = SummaryWriter(path)
	

	def record_value(self, name, data, step):
		self._writer.add_scalar(name, data, step)

	def record(self, name, data, step):
		#print('record', name, data, step)
		self._writer.add_scalars(name, data, step)

	def close(self):
		self._writer.close()

