//
//  AppDelegate.swift
//  Job Assistant
//
//  Created by Maruf Memon on 16/01/24.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print(paths[0])
        kOpenAI.setup()
        kKeychain.setup()
        kData.setup()
//        addJobsData()
//        kData.addUserProfile()
        // Override point for customization after application launch.
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        
    }
    
    func addJobsData() {
        kData.createJob(job_id: "linkedin_b0d953e9-652a-4452-9cc0-74cb4e26c3e8", job_description: """
Job Title: Software Engineer – iOS/MacOS Applications
Company: Hushh Intelligence Inc.
Job Type: Full-Time
Location: Remote / Global

About Hushh:
At Hushh, we're on a transformative mission to revolutionize how users interact with their personal and business data. We're committed to building a world where data serves its owners actively and intelligently. Our focus is on seamlessly integrating AI and data systems to enhance human life, leveraging on-device AI/ML for optimized efficiency.

We are a small, highly motivated team, deeply invested in engineering excellence. We encourage our engineers to embrace challenges, foster curiosity, and work across various company areas, embodying our belief in being "Members of Technical Staff."

We embrace a flat organizational structure, empowering all employees to contribute hands-on to our mission. Leadership at Hushh is earned through initiative and consistent delivery of excellence.

Your Role:
Develop cutting-edge applications for iOS, MacOS, and Apple Vision Pro.
Leverage the latest in Swift, iOS foundational libraries, and Apple's Vision framework.
Ensure high-performance, responsive experiences across Apple devices.
Collaboratively define and design new features, enhancing application performance.

Tech Stack:
Swift
iOS foundational libraries
Apple Vision framework
UIKit, Core Animation, Core Data, Core Graphics

Ideal Experience:
Proficiency in Swift and iOS foundational libraries.
Experience with Apple's Vision framework and Apple ecosystem development.
Strong understanding of iOS frameworks and Apple's design principles.

Qualifications:
Bachelor’s degree in Computer Science or related field.
Proven track record in iOS/MacOS application development.
Strong portfolio showcasing expertise in iOS frameworks and design principles.

Why Join Hushh?
Be part of a pioneering team redefining data management with AI.
Opportunity to work in an innovative, fast-paced environment.
Contribute to a mission that values user empowerment and data privacy.

Apply Now:
Join us at Hushh to shape the future of data management and AI integration within the Apple ecosystem. Send your application, including a resume and a cover letter showcasing your iOS/MacOS development expertise, to talent@hushh.ai.

Key Questions:
What exceptional work have you done in iOS/MacOS development?
Current company and role (if applicable).
LinkedIn Profile, X Profile, Google Scholar (if available).

Hushh is an equal opportunity employer, dedicated to diversity and creating an inclusive environment for all employees.
""", company_name: "hushh.ai", apply_link: "", job_role: "iOS Developer")
        kData.createJob(job_id: "linkedin_f7nhG3TDfbwmALOLhCZCcg", job_description: """
We're a 20 person company of early WeChat and WhatsApp veterans committed to reinventing the messaging app around native support for AI agents. Our agents seamlessly and naturally interact with individuals, groups, and one another both responsively and proactively. Our commitment is to a free and open future for AI, empowering the most people to make the most diverse use of the technology, bolstered by the open source ecosystem. We’re seeking a Lead iOS Engineer to lead our iOS client team in innovation and craftsmanship.



Compensation:

Highly competitive, commensurate with experience and skill level. Includes benefits, and equity options.



Key Responsibilities:

Technical Leadership: Spearhead the development of our iOS chat application, ensuring it's efficient, scalable, and polished.
Code Excellence: Write, review, and maintain high-performance Swift and Objective-C code.
Product Vision: Collaborate closely with the product, design, and engineering teams to influence product direction and functional requirements.
Innovation: Stay updated with the latest iOS development trends and technologies, ensuring our application always leverages the best available tools and practices.
Performance Tuning: Identify and resolve performance and scalability issues to ensure the app runs smoothly across all relevant iOS devices.
Mentoring: Foster a collaborative environment, guiding and mentoring junior developers, ensuring team-wide growth and cohesion.
Quality Assurance: Work alongside the QA team to ensure the stability and quality of the application.


Minimum Qualifications:

Bachelor’s or Master’s degree in Computer Science, Engineering, or a related field.
5+ years of professional iOS development experience, with at least 2 years in a lead or senior role.
Extensive experience with Swift and Objective-C.
Proven track record in designing and implementing complex mobile applications with a user-centric approach.
Familiarity with iOS frameworks such as UIKit, Core Data, Core Animation, etc.
Experience with iOS performance tools and optimization techniques.


Preferred Qualifications:

Experience with chat or messaging applications.
Contributions to open-source iOS projects or community.
Advanced degree in a relevant field.


What We Offer:

Competitive Compensation: Beyond a competitive salary, we offer bonuses, benefits, and stock options.
Growth: A challenging and rewarding work environment that values personal and professional growth.
Innovation: Opportunity to work on a cutting-edge product that's reshaping the world of communication.
Team: Join a passionate team that values transparency, collaboration, and continuous learning.


If you’re a visionary iOS Engineer with the expertise and passion to reshape the landscape of communication, we’d love to hear from you. Apply by sending your resume, a link to your GitHub or portfolio, and a brief cover letter to jobs@channel.surf
""", company_name: "Channel AI", apply_link: "", job_role: "Lead iOS Engineer")
        kData.createJob(
            job_id: "JD123",
            job_description: """
            We are looking for a talented iOS developer to join our dynamic team. In this role, you will be responsible for designing and implementing innovative mobile applications. If you are passionate about creating cutting-edge software and have a strong background in iOS development, we want to hear from you!
        
            Job Responsibilities:
            - Develop and maintain high-quality mobile applications for iOS platforms.
            - Collaborate with cross-functional teams to define, design, and ship new features.
            - Continuously discover, evaluate, and implement new technologies to maximize development efficiency.
        
            Requirements:
            1. What experience do you have in iOS app development?
            2. Can you provide an example of a complex feature you implemented in a previous iOS project?
            3. How do you ensure the performance, quality, and responsiveness of applications?
            4. Share your experience with version control systems, such as Git.
            5. Have you worked with RESTful APIs? If so, describe a scenario where you implemented API calls in your app.
        
            Qualifications:
            - Bachelor's degree in Computer Science or equivalent experience.
            - Strong problem-solving skills and attention to detail.
            - Excellent communication and teamwork skills.
        
            Apply now to be part of an exciting journey in mobile app development!
        """,
            company_name: "Tech Innovators",
            apply_link: "https://example.com/job-application",
            job_role: "iOS Developer"
        )
        kData.createJob(
            job_id: "JD456",
            job_description: """
            Exciting iOS Developer Opportunity!
        
            Are you passionate about iOS app development and eager to work on groundbreaking projects? Join our team at Innovative Solutions and be part of a collaborative environment where creativity and innovation thrive.
        
            Responsibilities:
            - Design and implement high-quality iOS applications.
            - Collaborate with cross-functional teams to define, design, and deliver new features.
            - Troubleshoot, debug, and optimize code for performance and usability.
        
            Qualifications:
            1. Strong experience in Swift and Objective-C programming languages.
            2. Proven track record of developing and releasing successful iOS applications.
            3. Familiarity with RESTful APIs and integration.
            4. Proficient understanding of code versioning tools such as Git.
            5. Excellent problem-solving and communication skills.
        
            To apply, please email your resume and cover letter to careers@innovativesolutions.com with the subject line "iOS Developer Application - JD456".
        
            Cover Letter Questions:
            1. Why are you interested in this iOS developer position?
            2. Share an example of a challenging problem you faced in a previous iOS project and how you resolved it.
            3. How do you stay updated on the latest trends and technologies in iOS development?
        
            We look forward to receiving your applications and learning more about your skills and experiences!
        """,
            company_name: "Innovative Solutions",
            apply_link: "",
            job_role: "iOS Developer"
        )
    }

}

