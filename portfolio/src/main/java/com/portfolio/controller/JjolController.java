package com.portfolio.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class JjolController {

	@GetMapping("/jjol")
	public String jjol() {
		return "views/jjol";
	}
}
