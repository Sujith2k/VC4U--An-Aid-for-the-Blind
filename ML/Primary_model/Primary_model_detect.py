import cv2

net = cv2.dnn.readNet("My Drive/yolov3/yolov3_training_last.weights", "My Drive/yolov3/yolov3_training.cfg")

classes = ['Person','Billboard','Bus','Traffic sign','Truck','Currency']

# Images path
img_path =                   # Fill the address Part

layer_names = net.getLayerNames()
output_layers = [layer_names[i[0] - 1] for i in net.getUnconnectedOutLayers()]
colors = np.random.uniform(0, 255, size=(len(classes), 3))



img = cv2.imread(img_path)
img = cv2.resize(img, None, fx=0.4, fy=0.4)
height, width, channels = img.shape
  
# Detecting objects
blob = cv2.dnn.blobFromImage(img, 0.00392, (416, 416), (0, 0, 0), True, crop=False)
  
net.setInput(blob)
outs = net.forward(output_layers)
  
# Showing informations on the screen
class_ids = []
confidences = []
boxes = []
for out in outs:
  for detection in out:
      scores = detection[5:]
      class_id = np.argmax(scores)
      confidence = scores[class_id]
      if confidence > 0.3:
          # Object detected
          print(classes[class_id],float(confidence))
          
          confidences.append(float(confidence))
          class_ids.append(class_id)
  

  

