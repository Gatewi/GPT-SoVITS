# Hướng Dẫn Sử Dụng GPT-SoVITS (Installation Packet)

Tài liệu này hướng dẫn chi tiết cách cài đặt, chạy Fine-tuning, và tích hợp API với Google Apps Script.

## 📋 1. Hướng Dẫn Cài Đặt & Chạy Dịch Vụ

## 🚀 How to Install (Cách cài đặt)

### Phương pháp 1: Copy từ Windows qua mạng (SCP) - Khuyên dùng

Nếu bạn đang ngồi máy Windows và muốn gửi file sang máy Ubuntu (Ví dụ IP: `192.168.1.17`), hãy mở **CMD** hoặc **PowerShell** trên Windows và chạy lệnh:

```cmd
scp "C:\setup\Antigravity\GPT-SoVITS\GPT-SoVITS-Installer.zip" fimi@192.168.1.17:~/tmp/
```
*   Thay `username` bằng tên người dùng trên máy Ubuntu (ví dụ: `ubuntu`, `root`, `fimi`).
*   Sau đó nhập mật khẩu của máy Ubuntu.

### Phương pháp 2: Copy qua USB hoặc Shared
2.  **Giải nén** (Trên máy Ubuntu):
    ```bash
    # Cài đặt unzip nếu chưa có
    sudo apt install unzip -y
    
    # Giải nén
    unzip GPT-SoVITS-Installer.zip -d gpt-sovits-installer
    
    # Vào thư mục
    cd gpt-sovits-installer
    ```
3.  **Cấp quyền & Chạy**:
    ```bash
    # Cấp quyền và chạy cài đặt
    chmod +x install.sh
    bash install.sh
    ```
4.  **Chọn chế độ cài đặt**: Bạn có thể chọn khi chạy script hoặc dùng lệnh nhanh:
    -   **Bản Lite (Khuyên dùng cho API)**: `bash install.sh lite`
    -   **Bản Full (Đầy đủ huấn luyện)**: `bash install.sh full`
    
    *Nếu chỉ chạy `bash install.sh`, script sẽ hiện menu cho bạn chọn.*

### 2. Start the WebUI (Fine-tuning)
Chỉ cần chạy file `run_webui.sh`:
```bash
chmod +x run_webui.sh
./run_webui.sh
```
Access via browser at `http://localhost:9874`.

### 1.3. Chạy Giao Diện Test Mẫu Giọng Có Sẵn (Zero-shot Inference cho bản Lite)
Tính năng này sẽ giúp bạn nhái lại bất cứ giọng nào (chỉ cần audio mồi gốc dài 5-10s) bằng bản Lite mà KHÔNG cần huấn luyện (Fine-tune).

1. Khởi động WebUI: `./run_webui.sh`
2. Mở trình duyệt Web của bạn và truy cập địa chỉ: `http://localhost:9874`
3. Tìm và mở "Inference WebUI":
   - Trên WebUI chính, vào thẻ (Tab) **1-GPT-SoVITS-TTS**.
   - Kéo xuống dưới cùng, tìm nút **Open TTS Inference WebUI** và bấm vào. Một cửa sổ Inference WebUI chuyên biệt để sinh giọng đọc sẽ hiện lên.
4. Thiết lập Audio mồi và Text:
   - **GPT & SoVITS Model:** Mặc định hệ thống đã chọn sẵn model V3/V4 tốt nhất.
   - **Reference Audio (âm thanh mồi):** Upload file audio chứa giọng điệu bạn muốn nhái (tiếng Việt, dài ~5-10 giây, chất lượng tốt/không tạp âm).
   - **Reference Text:** Gõ **chính xác** nội dung người trong audio mồi đang nói.
   - **Reference Language:** Chọn Tiếng Việt (`vi`).
   - **Target Text:** Nhập đoạn văn bản bạn muốn AI đọc.
   - **Target Language:** Chọn Tiếng Việt (`vi`).
5. Cuối cùng, nhấn **Synthesize**. Chờ một lát và bạn có thể bấm **Play** trên màn hình để nghe thử giọng đọc đã được "nhái" lại.

---

### 1.4. Chạy API (Để sử dụng TTS)
Dùng để đọc văn bản thành tiếng thông qua code hoặc HTTP Request.

## 🎙️ 2. Hướng Dẫn Fine-tuning (Huấn Luyện Giọng Mới)

Dưới đây là quy trình chi tiết để tạo một giọng nói clone hoàn chỉnh từ giao diện WebUI (`http://localhost:9874`):

### Giai đoạn 1: Xử Lý Dữ Liệu (Tab 0-Fetch Datasets)
1.  **Tách lời (UVR5 WebUI)**: Nếu file âm thanh gốc có nhạc nền, bấm **Open Vocal Separation WebUI**. Chọn model `HP2_all_vocals` để lấy giọng nói sạch nhất.
2.  **Cắt nhỏ (Speech Slicing)**: AI cần audio từ 3-10 giây.
    - **Input**: Đường dẫn file/thư mục đã tách lời.
    - **Output**: Thư mục lưu các đoạn cắt (mặc định là `output/slicer_opt`).
    - Bấm **Open Speech Slicing** để thực hiện.

### Giai đoạn 2: Quy Trình Huấn Luyện (Tab 1-GPT-SoVITS-TTS)
1.  **Bước 1A - Dataset formatting**:
    - Nhập tên Model vào **Experiment Name**.
    - Nhập đường dẫn thư mục đã cắt nhỏ vào **Audio dataset folder**.
    - Bấm **Start formatting**.
2.  **Bước 1B - ASR (Gán nhãn)**:
    - Chọn model `faster-whisper-large-v3`. Bấm **Start ASR**.
    - Sau khi xong, hãy vào tab **0-Data Labeling** phía dưới để kiểm tra và sửa lại văn bản nếu AI nghe sai.
3.  **Bước 1C - Preprocessing**: Bấm **Start Preprocessing**.
4.  **Bước 1D - Traning (Huấn luyện)**:
    - Chỉnh **Epoch** khoảng 10-15 lần cho GPT và 8-10 lần cho SoVITS.
    - Bấm **Start SoVITS training**, đợi xong rồi bấm **Start GPT training**.

### Giai đoạn 3: Kiểm Tra và Lấy Model
- Vào Tab **Inference** để chạy thử giọng mới.
- Các file model thành phẩm (`.pth` và `.ckpt`) sẽ nằm trong thư mục `GPT_SoVITS/weights/`. 
- Hãy copy chúng ra để sử dụng cho bản **Lite** hoặc API.

### 🇻🇳 Lưu ý quan trọng cho Tiếng Việt:
1.  **ASR Model**: Bắt buộc dùng `faster-whisper-large-v3` (đã có trong bản Full).
2.  **Ngôn ngữ Trainer**: Khi train, phần ASR sẽ tự nhận diện là `vi`. Nếu không, hãy chọn thủ công.
3.  **Base Model**: Có thể dùng `s1v3.ckpt` và `s2Gv3.pth` hoặc model V4 mới nhất (`gsv-v4-pretrained`) làm nền tảng. Phiên bản bộ cài đặt này đã tự động tải sẵn model V4 để sửa lỗi "Model Not Downloaded: V4" trên giao diện. GPT-SoVITS hỗ trợ "Zero-shot" rất tốt, nên chỉ cần data tiếng Việt sạch là model sẽ học được cách phát âm.

---

## ❓ FAQ (Câu hỏi thường gặp)

**Q: Tôi có cần cài `nvidia-container-toolkit` không?**
A: **Không.** Gói cài đặt này chạy native trên Conda.

**Q: Máy tôi có RTX 3060 nhưng chưa cài Driver?**
A: Trong gói này có sẵn script hỗ trợ cài Driver.
Bạn chạy lệnh sau rồi khởi động lại máy:
```bash
bash scripts/install_gpu_drivers.sh
sudo reboot
```
Sau đó mới chạy `bash install.sh`.

**Q: Nếu tôi muốn giọng clone chuẩn nhất, giống thật nhất thì nên làm gì?**
A: Chắc chắn là bạn nên **Fine-tuning (Huấn luyện riêng)**.
- **Zero-shot (Bản Lite)**: AI chỉ "nhìn" giọng bạn trong 5 giây rồi bắt chước ngay. Giọng sẽ khá giống nhưng ngữ điệu có thể hơi "lai" hoặc thỉnh thoảng bị lỗi phát âm tiếng Việt.
- **Fine-tuning (Bản Full)**: Bạn dạy AI bằng 15-30 phút giọng nói của mình. AI sẽ học sâu về cách bạn nhả chữ, nhấn nhá dấu câu tiếng Việt. Kết quả sẽ tự nhiên và ổn định hơn gấp nhiều lần.

## 💾 3. Sau khi Huấn luyện (Fine-tuning) xong thì giữ cái gì?

Bản **Lite** thực chất chỉ cần các "thành phẩm" cuối cùng để chạy. Sau khi bạn train xong giọng nói của mình, hãy giữ lại những thứ sau và có thể xóa bớt dữ liệu rác để nhẹ máy:

### 3.1 Những file CẦN GIỮ (Để chạy Lite + API):
-   **GPT Weight**: File `.ckpt` (thường nằm trong thư mục `GPT_weights_v3`).
-   **SoVITS Weight**: File `.pth` (thường nằm trong thư mục `SoVITS_weights_v3`).
-   **File âm thanh mẫu (Reference Audio)**: File `.wav` bạn dùng để nhái giọng.
-   Các mô hình gốc trong `GPT_SoVITS/pretrained_models` (Đã có sẵn khi cài Lite).

### 3.2 Những file CÓ THỂ XÓA (Để giải phóng dung lượng):
-   Thư mục `output`: Chứa các kết quả trung gian.
-   Thư mục `logs`: Chứa dữ liệu train cực nặng (có thể lên tới hàng chục GB).
-   Các file trong `tools/asr/models` (Nếu bạn đã cài bản Full thì sau khi train xong có thể xóa thư mục này để biến nó thành bản Lite).

---

## 🚀 4. Cách dùng Model đã Fine-tune với API

Sau khi bạn đã huấn luyện xong và có 2 file `.ckpt` (GPT) và `.pth` (SoVITS), bạn có thể chuyển sang dùng chúng cho API theo 2 cách:

### Cách 1: Khởi động API với model mới (Recommend)
Khi chạy lệnh khởi động API, hãy thêm tham số trỏ vào file model của bạn:
```bash
python api_v2.py -a 0.0.0.0 -p 9880 \
  -g GPT_SoVITS/weights/Tên_Model-e15.ckpt \
  -s GPT_SoVITS/weights/Tên_Model-e10.pth
```

### Cách 2: Đổi model "nóng" (Không cần restart)
Bạn có thể ra lệnh cho API nạp model mới ngay lập tức qua URL (rất hữu ích khi muốn đổi giọng liên tục):
- **Đổi GPT weights**:
  `http://IP_CUA_BAN:9880/set_gpt_weights?weights_path=GPT_SoVITS/weights/Tên_Model-e15.ckpt`
- **Đổi SoVITS weights**:
  `http://IP_CUA_BAN:9880/set_sovits_weights?weights_path=GPT_SoVITS/weights/Tên_Model-e10.pth`

---

## ☁️ 5. Google Apps Script Integration

Hàm dưới đây giúp bạn gửi văn bản lên server Ubuntu và lưu file MP3 về Google Drive.

### Thiết lập Server
*   Đảm bảo Server Ubuntu của bạn có **Public IP** (hoặc dùng ngrok).
*   Đã mở port `9880` (Firewall).

### Code Apps Script (`Code.gs`)

```javascript
// Thay đổi IP này thành IP Public của Server Ubuntu của bạn
const HOST_URL = "http://relay0.ddns.net:9880"; 

/**
 * Hàm gọi GPT-SoVITS API và lưu file vào Drive
 * @param {string} text - Văn bản cần đọc
 * @param {string} filename - Tên file lưu trên Drive (VD: 'audio.mp3')
 */
function textToSpeech(text, filename) {
  const url = HOST_URL + "/tts"; // Endpoint TTS (kiểm tra lại docs API nếu endpoint khác)
  
  // Cấu hình Payload (JSON)
  // Lưu ý: Cần chỉnh các tham số này cho phù hợp với Model bạn đang chạy
  const payload = {
    "text": text,
    "text_lang": "vi", // Hoặc 'en', 'zh', 'ja'
    "ref_audio_path": "path/to/ref.wav", // Đường dẫn file mẫu TRÊN SERVER UBUNTU
    "prompt_text": "Nội dung của file mẫu.", // Nội dung file mẫu
    "prompt_lang": "vi",
    "top_k": 5,
    "top_p": 1,
    "temperature": 1,
    "text_split_method": "cut5",
    "batch_size": 1,
    "batch_threshold": 0.75,
    "split_bucket": true,
    "speed_factor": 1.0,
    "streaming_mode": false,
    "seed": -1,
    "parallel_infer": true,
    "repetition_penalty": 1.35
  };

  const options = {
    "method": "post",
    "contentType": "application/json",
    "payload": JSON.stringify(payload),
    "muteHttpExceptions": true
  };

  Logger.log("Đang gọi API: " + url);
  
  try {
    const response = UrlFetchApp.fetch(url, options);
    const responseCode = response.getResponseCode();
    
    if (responseCode === 200) {
      // Lấy Blob (Binary Audio)
      const audioBlob = response.getBlob();
      audioBlob.setName(filename || "tts_output.mp3");
      
      // Lưu vào Root Google Drive
      const file = DriveApp.createFile(audioBlob);
      Logger.log("Thành công! File đã lưu tại: " + file.getUrl());
      return file.getUrl();
    } else {
      Logger.log("Lỗi API (" + responseCode + "): " + response.getContentText());
      return null;
    }
  } catch (e) {
    Logger.log("Lỗi kết nối: " + e.toString());
    return null;
  }
}

/**
 * Hàm test chạy thử
 */
function testTTS() {
  textToSpeech("Xin chào, đây là kiểm thử giọng nói từ Google Apps Script.", "test_voice.wav");
}
```

### Lưu ý quan trọng khi dùng Apps Script:
1.  **Reference Audio (`ref_audio_path`)**: File mẫu này **PHẢI NẰM TRÊN SERVER UBUNTU**, không phải trên Drive. Bạn nên upload 1 file mẫu chuẩn (ví dụ `mau_giong.wav`) lên server và điền đường dẫn tuyệt đối vào code.
2.  **IP Public**: Apps Script không thể gọi `localhost` hay `192.168.x.x`. Server phải có IP công khai hoặc dùng Tunnel (như Ngrok).
3.  **Timeout**: Apps Script giới hạn thời gian chạy (khoảng 6 phút), nhưng `UrlFetchApp` chờ khoảng 60s. Nếu Server GPU yếu, API có thể bị timeout.
