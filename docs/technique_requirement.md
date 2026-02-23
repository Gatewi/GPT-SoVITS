Triển khai \*\*GPT-SoVITS\*\* làm dịch vụ API trên máy chủ \*\*Ubuntu\*\* nhằm mục đích đọc văn bản (TTS), đặc biệt là với phiên bản mới nhất (V2, V3) có chất lượng vượt trội, bạn cần tuân thủ quy trình cài đặt kỹ thuật dưới đây.



\*\*Lưu ý quan trọng về Tiếng Việt:\*\* Phiên bản gốc của GPT-SoVITS hỗ trợ chính thức 5 ngôn ngữ: Trung, Anh, Nhật, Hàn, và Quảng Đông. Để đọc \*\*Tiếng Việt\*\*, bạn sẽ cần \*\*Huấn luyện (Fine-tune)\*\* mô hình với dữ liệu tiếng Việt hoặc sử dụng một checkpoint đã được cộng đồng huấn luyện sẵn cho tiếng Việt. Tài liệu dưới đây hướng dẫn thiết lập \*\*hạ tầng phần mềm (Infrastructure)\*\* để chạy API, nền tảng này sẽ dùng để chạy bất kỳ mô hình ngôn ngữ nào bạn nạp vào.



Dưới đây là tài liệu kỹ thuật chi tiết dành cho người mới.



---



\# TÀI LIỆU KỸ THUẬT: TRIỂN KHAI API GPT-SoVITS TRÊN UBUNTU



\## 1. Yêu cầu hệ thống và Phần mềm phụ trợ



Trước khi cài đặt GPT-SoVITS, bạn cần chuẩn bị môi trường phần cứng và cài đặt các phần mềm nền tảng.



\### Phần cứng (Khuyến nghị)

\*   \*\*GPU:\*\* NVIDIA GPU với tối thiểu \*\*6GB VRAM\*\* (để chạy mượt mà và tốc độ cao).

\*   \*\*RAM:\*\* 16GB trở lên.

\*   \*\*Ổ cứng:\*\* Khoảng 20GB dung lượng trống.



\### Phần mềm phụ trợ (Prerequisites)

Bạn cần cài đặt các gói sau trên Ubuntu trước khi đi vào cài đặt chính:



1\.  \*\*NVIDIA Drivers \& CUDA Toolkit:\*\* Để GPU hoạt động (Khuyến nghị CUDA 11.8 hoặc 12.x).

2\.  \*\*Conda (Miniconda/Anaconda):\*\* Quản lý môi trường Python ảo, tránh xung đột thư viện.

3\.  \*\*FFmpeg:\*\* Công cụ xử lý âm thanh bắt buộc.

4\.  \*\*Các công cụ biên dịch cơ bản:\*\* `build-essential`, `git`.



\*\*Câu lệnh cài đặt phần mềm phụ trợ:\*\*



Mở Terminal (Ctrl+Alt+T) và chạy lần lượt:



```bash

\\# 1. Cập nhật hệ thống

sudo apt update \\\&\\\& sudo apt upgrade -y



\\# 2. Cài đặt FFmpeg và các thư viện cần thiết

sudo apt install ffmpeg libsox-dev git build-essential -y



\\# 3. Cài đặt Miniconda (nếu chưa có)

mkdir -p ~/miniconda3

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86\\\_64.sh -O ~/miniconda3/miniconda.sh

bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3

rm -rf ~/miniconda3/miniconda.sh

source ~/miniconda3/bin/activate

conda init bash

\\# Sau bước này, hãy đóng Terminal và mở lại để Conda có hiệu lực.

```



---



\## 2. Quy trình Cài đặt GPT-SoVITS



Chúng ta sẽ sử dụng mã nguồn từ GitHub chính thức và thiết lập môi trường qua Conda.



\### Bước 1: Tải mã nguồn (Clone Repository)

```bash

cd ~

git clone https://github.com/RVC-Boss/GPT-SoVITS.git

cd GPT-SoVITS

```



\### Bước 2: Tạo môi trường ảo

Tạo môi trường Python 3.10 chuyên biệt cho GPT-SoVITS:

```bash

conda create -n GPTSoVits python=3.10 -y

conda activate GPTSoVits

```



\### Bước 3: Cài đặt thư viện phụ thuộc

Bạn sử dụng script `install.sh` có sẵn để tự động cài đặt các thư viện Python (PyTorch, torchaudio, v.v.) phù hợp.



```bash

\\# Cấp quyền thực thi cho script

chmod +x install.sh



\\# Chạy script cài đặt (Lựa chọn phiên bản CUDA phù hợp với máy bạn, ví dụ cu118 hoặc cu121)

\\# Nếu bạn không chắc chắn, dùng lệnh `nvidia-smi` để xem CUDA version máy hỗ trợ.

bash install.sh

```

\*Lưu ý:\* Nếu bạn gặp lỗi trong quá trình này, bạn có thể cài đặt thủ công bằng lệnh: `pip install -r requirements.txt`.



---



\## 3. Tải Mô hình (Pretrained Models)



Để chạy được API, bạn cần tải các mô hình gốc. Hiện tại phiên bản \*\*V3\*\* được khuyến nghị vì khả năng sao chép giọng nói zero-shot tốt hơn và ổn định hơn.



Bạn cần tải các file sau và đặt vào thư mục `GPT\\\_SoVITS/pretrained\\\_models`:



1\.  \*\*Mô hình GPT-SoVITS V3:\*\* `s1v3.ckpt` và `s2Gv3.pth`.

2\.  \*\*Mô hình Vocoder:\*\* Thư mục `models--nvidia--bigvgan\\\_v2\\\_24khz\\\_100band\\\_256x`.

3\.  \*\*Mô hình tách lời (nếu cần xử lý audio mẫu):\*\* UVR5 weights.



\*\*Cách tải nhanh (sử dụng HuggingFace CLI):\*\*

```bash

\\# Cài đặt công cụ tải

pip install huggingface\\\_hub



\\# Tải các model V3 (Ví dụ minh họa, bạn có thể tải thủ công từ link HuggingFace nếu muốn)

huggingface-cli download lj1995/GPT-SoVITS --include "s1v3.ckpt" --local-dir GPT\\\_SoVITS/pretrained\\\_models

huggingface-cli download lj1995/GPT-SoVITS --include "s2Gv3.pth" --local-dir GPT\\\_SoVITS/pretrained\\\_models



\\# Tải mô hình ASR (Nhận diện giọng nói) - Cần cho tiếng Trung/Anh, tiếng Việt có thể bỏ qua nếu chỉ inference

\\# Nhưng để tránh lỗi thiếu file, nên tải Whisper:

huggingface-cli download systran/faster-whisper-large-v3 --local-dir tools/asr/models/faster-whisper-large-v3

```



---



\## 4. Cấu hình và Chạy Dịch vụ API



GPT-SoVITS cung cấp sẵn file `api\\\_v2.py` để chạy server API.



\### Chạy API Server

Trong thư mục gốc `GPT-SoVITS`, chạy lệnh sau:



```bash

\\# Cấu trúc: python api\\\_v2.py -a \\\[IP Host] -p \\\[Port] -c \\\[Đường dẫn file config]

python api\\\_v2.py -a 127.0.0.1 -p 9880 -c GPT\\\_SoVITS/configs/s2.json

```

\*   `-a 0.0.0.0`: Nếu bạn muốn truy cập API từ máy khác trong mạng LAN (thay vì chỉ localhost).

\*   `-p 9880`: Cổng mặc định (bạn có thể đổi).



Khi thấy thông báo `Uvicorn running on http://127.0.0.1:9880`, nghĩa là server đã sẵn sàng.



---



\## 5. Hướng dẫn Sử dụng API (Đọc tiếng Việt)



Sau khi server chạy, bạn có thể gửi yêu cầu (Request) để tạo giọng nói.



Do mô hình gốc không có tiếng Việt, bạn có 2 cách tiếp cận khi gọi API:

1\.  \*\*Dùng mô hình gốc (Tiếng Anh/Trung) để đọc tiếng Việt không dấu/hoặc phiên âm:\*\* Chất lượng sẽ thấp và giọng lơ lớ.

2\.  \*\*Dùng mô hình đã Fine-tune tiếng Việt:\*\* Bạn cần thay đổi đường dẫn model khi khởi chạy hoặc dùng API đổi model (set\_model).



\### API Endpoints Chính

Bạn có thể truy cập `http://127.0.0.1:9880/docs` để xem tài liệu Swagger UI đầy đủ. Dưới đây là ví dụ gọi API cơ bản để đọc văn bản.



\*\*Endpoint:\*\* `POST /tts` hoặc `GET /tts` (Tùy phiên bản API, V2 thường dùng GET/POST linh hoạt).



\*\*Ví dụ lệnh CURL (Test trên Terminal):\*\*



```bash

curl -X 'POST' \\\\

\&nbsp; 'http://127.0.0.1:9880/tts' \\\\

\&nbsp; -H 'Content-Type: application/json' \\\\

\&nbsp; -d '{

\&nbsp; "text": "Xin chào, đây là thử nghiệm giọng nói tiếng Việt.",

\&nbsp; "text\\\_lang": "vi", 

\&nbsp; "ref\\\_audio\\\_path": "path/to/mau\\\_giong\\\_tieng\\\_viet.wav",

\&nbsp; "prompt\\\_text": "Nội dung của file mẫu giọng nói",

\&nbsp; "prompt\\\_lang": "vi",

\&nbsp; "top\\\_k": 5,

\&nbsp; "top\\\_p": 1,

\&nbsp; "temperature": 1,

\&nbsp; "text\\\_split\\\_method": "cut5"

}'

```



\*\*Giải thích tham số:\*\*

\*   `text`: Văn bản cần đọc.

\*   `text\\\_lang`: Ngôn ngữ văn bản. \*\*Lưu ý:\*\* Nếu dùng bản gốc, bạn phải chọn `en`, `zh`, `ja`... Nếu dùng bản fine-tune tiếng Việt, bạn cần kiểm tra xem người huấn luyện đặt tag ngôn ngữ là gì (thường họ sẽ map vào `en` hoặc `all` nếu chưa sửa code nguồn).

\*   `ref\\\_audio\\\_path`: Đường dẫn đến file âm thanh mẫu (giọng người bạn muốn nhái) nằm trên máy chủ Ubuntu (từ 3-10 giây).

\*   `prompt\\\_text`: Nội dung lời nói trong file âm thanh mẫu.

\*   `text\\\_split\\\_method`: Cách cắt câu (ví dụ `cut5` là cắt theo dấu câu).



\### Tóm tắt các phần mềm/công cụ cần thiết nhất:

1\.  \*\*Hệ điều hành:\*\* Ubuntu 20.04 hoặc 22.04.

2\.  \*\*Quản lý môi trường:\*\* Miniconda.

3\.  \*\*Ngôn ngữ lập trình:\*\* Python 3.10.

4\.  \*\*Xử lý âm thanh:\*\* FFmpeg.

5\.  \*\*Driver:\*\* NVIDIA Drivers + CUDA 11.8/12.x.

6\.  \*\*Mã nguồn:\*\* GPT-SoVITS (GitHub).

7\.  \*\*Model:\*\* Pretrained V3 Models (từ HuggingFace).



Sau khi hoàn tất cài đặt, để có chất lượng tiếng Việt tốt nhất, bạn nên tìm kiếm các cộng đồng chia sẻ checkpoint GPT-SoVITS tiếng Việt hoặc tự thu âm giọng mình (khoảng 1 phút đến 1 tiếng) để thực hiện quá trình "Fine-tuning" trên giao diện WebUI (`go-webui.bat` trên Windows hoặc `python webui.py` trên Linux) trước khi chạy API.

