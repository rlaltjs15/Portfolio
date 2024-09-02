package com.eda.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class EdaController {

    // 메인 페이지 이동
    @GetMapping("/eda")
    public String showMainPage() {
        return "views/eda";
    }
}
