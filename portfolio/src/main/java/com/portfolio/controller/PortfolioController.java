package com.portfolio.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class PortfolioController {

	//Main Page
	@GetMapping("/portfolio")
	public String portfolio() {
		return "views/portfolio";
	}
}
