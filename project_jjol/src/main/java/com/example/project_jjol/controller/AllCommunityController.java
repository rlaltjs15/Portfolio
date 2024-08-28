package com.example.project_jjol.controller;

import java.io.PrintWriter;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.project_jjol.model.AllCommunity;
import com.example.project_jjol.model.CommunityComment;
import com.example.project_jjol.model.User;
import com.example.project_jjol.service.AllCommunityService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
public class AllCommunityController {

	@Autowired
	private AllCommunityService allCommunityService;
	
	// 글 리스트 보기
	// 페이징 처리
	@GetMapping("/AllCommunityView")
	public String allCommunity(Model model, HttpServletRequest request,
			@RequestParam(value = "pageNum", defaultValue = "1") int pageNum,
			@RequestParam(value = "type", defaultValue = "all") String type,
			@RequestParam(value = "keyword", defaultValue = "") String keyword) {
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("loggedInUser") == null) {
			return "redirect:/login";
		}
		if (pageNum < 1) {
			pageNum = 1;
		}
		int pageSize = 10;
		int startRow = (pageNum - 1) * pageSize;
		List<AllCommunity> communityList;
		if ("all".equals(type)) {
			// 모든 타입에서 검색
			communityList = allCommunityService.selectCommunityListForAll(startRow, pageSize, keyword);
		} else {
			// 특정 타입에서 검색
			communityList = allCommunityService.selectCommunityList(startRow, pageSize, type, keyword);
		}
		int totalCount;

		if ("all".equals(type)) {
			// 모든 타입에서의 총 개수
			totalCount = allCommunityService.getCommunityCountForAll(keyword);
		} else {
			// 특정 타입에서의 총 개수
			totalCount = allCommunityService.getCommunityCount(type, keyword);
		}
		
		int pageCount = (totalCount + pageSize - 1) / pageSize;
		int pageGroupSize = 10;
		int startPage = ((pageNum - 1) / pageGroupSize) * pageGroupSize + 1;
		int endPage = Math.min(startPage + pageGroupSize - 1, pageCount);
		int pageGroup = (startPage - 1) / pageGroupSize;
		int currentPage = pageNum;
		model.addAttribute("communityList", communityList);
		model.addAttribute("totalCount", totalCount);
		model.addAttribute("startPage", startPage);
		model.addAttribute("endPage", endPage);
		model.addAttribute("pageCount", pageCount);
		model.addAttribute("pageGroup", pageGroup);
		model.addAttribute("currentPage", currentPage);
		model.addAttribute("type", type);
		model.addAttribute("keyword", keyword);
		return "views/AllCommunity_View";
	}

	// 글 상세보기
	   @GetMapping("/AllCommunityViewDetail")
	    public String AllCommunityViewDetail(@RequestParam("no") int no, Model model, HttpSession session) {
	        AllCommunity allcommunity = allCommunityService.findByNo(no);
	        User loggedInUser = (User) session.getAttribute("loggedInUser");

	        if (allcommunity == null) {
	            return "redirect:/AllCommunityView";
	        }

	        List<CommunityComment> commentsList = allCommunityService.getCommentsByccNo(no);
	        log.info("commentsList :" + commentsList);

	        model.addAttribute("allcommunity", allcommunity);
	        model.addAttribute("commentsList", commentsList);

	        // 로그인된 사용자가 있는 경우에만 사용자 이름을 모델에 추가
	        if (loggedInUser != null) {
	            String userName = loggedInUser.getName(); // 사용자 이름 또는 식별자 필드
	            model.addAttribute("loggedInUser", userName);
	        }

	        return "views/AllCommunity_Detail";
	    }

	// 글쓰기 폼 요청
	@GetMapping("AllCommunityWrite")
	public String addAllcadd() {
		return "views/AllCommunity_Write";
	}

	// 글쓰기 요청 처리
	@PostMapping("/AllCommunityWrite")
	public String saveAllc(AllCommunity allcommunity,@RequestParam(value = "dateAllc") Date dateAllc, RedirectAttributes redirectAttributes) throws Exception {
		Timestamp myDate = new Timestamp(dateAllc.getTime());
		allcommunity.setAllcDate(myDate);
		log.info("AllCommunityWrite - controller : " + allcommunity.getAllcName());
		AllCommunity saveAllc = allCommunityService.insertuser(allcommunity);
		return "redirect:/AllCommunityView";
	}

	// 글 삭제하기
	@PostMapping("/deleteAllCommunity")
	public String dleteAllcommunity(HttpServletResponse resonse, PrintWriter out, @RequestParam("allcNo") int no) {
		allCommunityService.deleteAllCommunity(no);
		return "redirect:/AllCommunityView";
	}

	// 글 수정 폼 이동
	@GetMapping("/updateAllCommunityForm")
	public String updateAllCommunityForm(@RequestParam("no") int no, Model model) {
		AllCommunity allcommunity = allCommunityService.findByNo(no);
		model.addAttribute("allcommunity", allcommunity);
		return "views/AllCommunity_Update";
	}

	// 글 수정하기
	@PostMapping("/updateAllCommunity")
	public String updateAllCommunity(@ModelAttribute("allcommunity") AllCommunity allcommunity) {
		allCommunityService.updateAllCommunity(allcommunity);
		return "redirect:/AllCommunityView";
	}

	// 댓글 추가
	@PostMapping("/comments/cccommentadd")
	@ResponseBody
	public List<CommunityComment> cccommentadd(@RequestBody CommunityComment communitycomment, HttpSession session) {

		log.info("cmcComment : " + communitycomment.getCmcContent() + ", writer : " + communitycomment.getCmcWriter());

		User user = (User) session.getAttribute("loggedInUser");
		
		allCommunityService.insertcommunitycomment(communitycomment);
		communitycomment.setCmcWriter(null);
		
		return allCommunityService.getCommentsByccNo(communitycomment.getCcNo());

	}

//	// 특정 데이터 번호에 해당하는 모든 댓글 가져오기
//	@GetMapping("/comments/cmcNo/{no}")
//	@ResponseBody
//	public List<CommunityComment> getCommentsByccNo(@PathVariable("no") int no) {
//		return allCommunityService.getCommentsByccNo(no);
//	}

	@PostMapping("/deleteComment")
	@ResponseBody
	public List<CommunityComment> deleteCommunityComment(
			@RequestParam("commentId") int commentId,
			@RequestParam("no") int no) {
		// 댓글 삭제 로직
		boolean deleted = allCommunityService.deleteCommunityComment(commentId); // 예시: 실제 서비스 메소드 호출

		return allCommunityService.getCommentsByccNo(no);
		
		/*
		if (deleted) {
			return ResponseEntity.ok("댓글이 성공적으로 삭제되었습니다.");
		} else {
			return ResponseEntity.badRequest().body("댓글 삭제에 실패했습니다.");
		}
		*/
	}

}