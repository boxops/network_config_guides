import os

ip_list = ["10.11.0.62","10.11.0.63","10.11.0.67","10.11.0.68","10.11.0.69","10.11.0.70","10.11.0.71","10.11.0.72","10.11.0.73","10.11.0.74","10.11.0.75","10.11.0.76"]

pingable = []
not_pingable = []

for ip in ip_list:
	ping = os.system(f"ping -n 2 {ip}")
	if ping == 0: # if IP is pingable
		print(f"{ip} is online.")
		pingable.append(ip)
	else:
		print(f"{ip} is offline.")
		not_pingable.append(ip)

print(pingable)
print(not_pingable)
