# 경북 병원·약국 데이터 변환

## 입력 파일

`raw` 폴더에 다음 파일을 둡니다.

- `hospitals_2026-06.xlsx`: 병원정보서비스
- `pharmacies_2026-06.xlsx`: 약국정보서비스
- `departments_2026-06.xlsx`: 의료기관별 진료과목정보

원본 XLSX는 Git에 포함하지 않습니다.

## 실행

저장소의 `APAYO` 폴더에서 실행합니다.

```bash
python3 -m pip install -r DataPipeline/requirements.txt
python3 DataPipeline/convert_medical_facilities.py
```

## 결과

동일한 JSON이 다음 두 위치에 저장됩니다.

- `DataPipeline/output/GyeongbukMedicalFacilities.json`: 변환 결과 확인용
- `APAYO/Resources/Data/GyeongbukMedicalFacilities.json`: iOS 앱 번들용

진료과목은 `암호화요양기호`를 기준으로 병원별 배열로 합쳐집니다.
병원은 `category: "hospital"`, 약국은 `category: "pharmacy"`로 구분됩니다.
