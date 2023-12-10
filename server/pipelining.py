import requests


start = 0
end = 17

uuid = '20231208T164356-0500_2D50E931-A486-4EDE-A859-2982CCB91A95'

for i in range(start, end + 1):
    print(f"processing: {i:02d}")
    
    url = f'http://localhost:5000/process/{uuid}-{i:02d}?overwrite=0&actions=["convert", "recons", "texturing", "segmentation", "render", "thumbnail"]'
    
    requests.get(url, timeout=3600*24)
