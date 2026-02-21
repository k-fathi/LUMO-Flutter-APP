import sys
from PIL import Image

def remove_white_background(input_path, output_path, tolerance=240):
    try:
        img = Image.open(input_path)
        img = img.convert("RGBA")
        datas = img.getdata()
        
        newData = []
        for item in datas:
            # If the pixel is close to white, make it transparent
            if item[0] > tolerance and item[1] > tolerance and item[2] > tolerance:
                newData.append((255, 255, 255, 0))
            else:
                newData.append(item)
                
        img.putdata(newData)
        img.save(output_path, "PNG")
        print(f"Successfully processed {input_path} -> {output_path}")
    except Exception as e:
        print(f"Error processing image: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python process.py <input> <output>")
        sys.exit(1)
    remove_white_background(sys.argv[1], sys.argv[2])
