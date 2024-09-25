var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
var tooltipList = tooltipTriggerList.map(function(tooltipTriggerEl) {
	return new bootstrap.Tooltip(tooltipTriggerEl);
});

//jjol img 자동 클릭
let index = 0;
const images = document.querySelectorAll('.jjol-img');
const totalImages = images.length;

// 현재 이미지를 표시하는 함수
function showImage() {
    images.forEach((img, i) => {
        img.style.display = (i === index) ? 'block' : 'none'; // 현재 인덱스의 이미지만 표시
    });
}

// 다음 이미지로 이동하는 함수
function nextImage() {
    index = (index + 1) % totalImages; // 인덱스를 증가시키고, 마지막 이미지 다음에는 처음으로 돌아감
    showImage();
}

// 이전 이미지로 이동하는 함수
function prevImage() {
    index = (index - 1 + totalImages) % totalImages; // 인덱스를 감소시키고, 처음 이미지 이전에는 마지막으로 돌아감
    showImage();
}

// 다음 이미지 버튼 클릭 시
document.querySelector('.next-button').addEventListener('click', nextImage);
// 이전 이미지 버튼 클릭 시
document.querySelector('.prev-button').addEventListener('click', prevImage);

// 초기 이미지 표시
showImage();


const images1 = document.querySelectorAll('.jjol-img');
const tooltip = document.getElementById('image-tooltip');

// 마우스가 이미지 위에 올라갔을 때
images.forEach(img => {
    img.addEventListener('mouseenter', (e) => {
        const title = img.getAttribute('data-title'); // 이미지의 data-title 값 가져오기
        tooltip.textContent = title; // 툴팁에 글씨 설정
        tooltip.style.opacity = 1; // 툴팁 보이기
    });

    // 마우스가 이미지 위에서 움직일 때
    img.addEventListener('mousemove', (e) => {
        tooltip.style.left = e.pageX + 15 + 'px'; // 마우스 커서 위치에 따라 좌우 이동
        tooltip.style.top = e.pageY + 15 + 'px'; // 마우스 커서 위치에 따라 상하 이동
    });

    // 마우스가 이미지에서 벗어났을 때
    img.addEventListener('mouseleave', () => {
        tooltip.style.opacity = 0; // 툴팁 숨기기
    });
});
