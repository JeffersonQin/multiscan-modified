import os
import os.path as osp
import json
import shutil
import tqdm
import math


#### Configurations ####
src = '20231208T164356-0500_2D50E931-A486-4EDE-A859-2982CCB91A95'
unit = 600
frame_skip = 10
########################


root_dir = osp.abspath(osp.dirname(__file__))
staging_dir = osp.join(root_dir, 'staging')

src_dir = osp.join(staging_dir, src)


with open(osp.join(src_dir, f'{src}.json'), 'r') as f:
    json_dict = json.load(f)
    total_frames = json_dict['streams'][0]['number_of_frames']

# 左闭右开 [)
# key_sep_frames = [0, 621, 1462, 1820, 2527, 3116, 3773, 4330, 5107, 5992, 6659, 7274, 8007, 8670, 9238, 9945, 10607, 11085, 11725]

key_sep_frames = [0]
curr = 0

while curr < math.ceil(total_frames / frame_skip):
    curr += unit
    curr = min(curr, math.ceil(total_frames / frame_skip))
    key_sep_frames.append(curr)

print("key frame seperation : ", key_sep_frames)
print("start index:", 0)
print("end index:", len(key_sep_frames) - 3)

for i in range(len(key_sep_frames) - 2):
    print(f":: cropping part {i:02d}")

    start_frame = key_sep_frames[i]
    end_frame = key_sep_frames[i + 2]

    start_depth = start_frame * frame_skip
    end_depth = min(end_frame * frame_skip, total_frames)
    
    dst = f'{src}-{i:02d}'
    dst_dir = osp.join(staging_dir, dst)

    os.makedirs(dst_dir, exist_ok=True)

    print(f":: cropping {src} from {start_frame} to {end_frame} ({end_frame - start_frame} frames)")
    print(f":: cropping {src} from {start_depth} to {end_depth} ({end_depth - start_depth} depth frames)")
    print(f":: saving to {dst_dir}")

    # copy {src_dir}/{src}.json to {dst_dir}/{dst}.json
    # copy {src_dir}/{src}.jsonl to {dst_dir}/{dst}.jsonl
    # copy {src_dir}/{src}.depth.zlib to {dst_dir}/{dst}.depth.zlib
    # copy {src_dir}/{src}.confidence.zlib to {dst_dir}/{dst}.confidence.zlib
    # copy {src_dir}/{src}.mp4 to {dst_dir}/{dst}.mp4
    shutil.copyfile(osp.join(src_dir, f'{src}.json'), osp.join(dst_dir, f'{dst}.json'))
    shutil.copyfile(osp.join(src_dir, f'{src}.jsonl'), osp.join(dst_dir, f'{dst}.jsonl'))
    shutil.copyfile(osp.join(src_dir, f'{src}.depth.zlib'), osp.join(dst_dir, f'{dst}.depth.zlib'))
    shutil.copyfile(osp.join(src_dir, f'{src}.confidence.zlib'), osp.join(dst_dir, f'{dst}.confidence.zlib'))
    shutil.copyfile(osp.join(src_dir, f'{src}.mp4'), osp.join(dst_dir, f'{dst}.mp4'))
    
    # modify json file
    print(f":: {i:02d} modifying {dst}.json")
    with open(osp.join(dst_dir, f'{dst}.json'), 'r') as f:
        json_dict = json.load(f)
        for stream_obj in json_dict['streams']:
            stream_obj['number_of_frames'] = end_depth - start_depth
    # save json file
    with open(osp.join(dst_dir, f'{dst}.json'), 'w') as f:
        json.dump(json_dict, f, indent=4)
        
    # modify jsonl file
    print(f":: {i:02d} modifying {dst}.jsonl")
    with open(osp.join(dst_dir, f'{dst}.jsonl'), 'r') as f:
        jsonl_list = f.readlines()
        jsonl_list = jsonl_list[start_depth:end_depth]
    # save jsonl file
    with open(osp.join(dst_dir, f'{dst}.jsonl'), 'w') as f:
        f.writelines(jsonl_list)

    # create {dst_dir}/outputs/color
    # copy {src_dir}/outputs/color/{i}.png to {dst_dir}/outputs/color/{i}.png
    # i with in [start_frame, end_frame)
    os.makedirs(osp.join(dst_dir, 'outputs/color'), exist_ok=True)
    for i in tqdm.tqdm(range(start_frame, end_frame)):
        shutil.copyfile(osp.join(src_dir, 'outputs/color', f'{i}.png'), osp.join(dst_dir, 'outputs/color', f'{i}.png'))
    
    # create {dst_dir}/outputs/depth
    # copy {src_dir}/outputs/depth/{i}.png to {dst_dir}/outputs/depth/{i}.png
    # i with in [start_depth, end_depth)
    os.makedirs(osp.join(dst_dir, 'outputs/depth'), exist_ok=True)
    for i in tqdm.tqdm(range(start_depth, end_depth)):
        shutil.copyfile(osp.join(src_dir, 'outputs/depth', f'{i}.png'), osp.join(dst_dir, 'outputs/depth', f'{i}.png'))
