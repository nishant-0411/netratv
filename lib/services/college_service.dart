class CollegeService {
  /// Mapping quiz options → categories
  static final Map<String, String> optionToCategory = {
    // 📘 Science → Medical
    "Surgeon": "medical",
    "Pediatrician": "medical",
    "Psychiatrist": "medical",
    "Cardiologist": "medical",

    // 📗 Maths → Engineering
    "AI / ML": "engineering",
    "Data Science": "engineering",
    "Mechanical": "engineering",
    "Civil": "engineering",
    "Electrical": "engineering",

    // 📙 Commerce
    "Chartered Accountant": "commerce",
    "Finance Analyst": "commerce",
    "Investment Banker": "commerce",
    "Auditor": "commerce",

    // 📕 Arts → Law
    "Journalist": "law",
    "Writer": "law",
    "Teacher": "law",
    "Lawyer": "law",

    // 📒 Computer Science → Engineering
    "Software Engineer": "engineering",
    "Cyber Security": "engineering",
    "Web Developer": "engineering",
    "App Developer": "engineering",
  };

  /// Static college data
  static final Map<String, List<Map<String, dynamic>>> _staticData = {
    "engineering": [
      {
        "name": "IIT Bombay",
        "type": "government",
        "country": "India",
        "address": "Powai, Mumbai, Maharashtra",
        "phone": "+91-22-2572-2545",
        "email": "office@iitb.ac.in",
        "website": "https://www.iitb.ac.in",
        "admission_info": "JEE Advanced for B.Tech",
        "exam": "JEE Advanced",
      },
      {
        "name": "IIT Delhi",
        "type": "government",
        "country": "India",
        "address": "Hauz Khas, New Delhi",
        "phone": "+91-11-2659-7135",
        "email": "office@iitd.ac.in",
        "website": "https://home.iitd.ac.in",
        "admission_info": "JEE Advanced for B.Tech",
        "exam": "JEE Advanced",
      },
      {
        "name": "IIT Madras",
        "type": "government",
        "country": "India",
        "address": "Chennai, Tamil Nadu",
        "phone": "+91-44-2257-8100",
        "email": "office@iitm.ac.in",
        "website": "https://www.iitm.ac.in",
        "admission_info": "JEE Advanced for B.Tech",
        "exam": "JEE Advanced",
      },
      {
        "name": "BITS Pilani",
        "type": "private",
        "country": "India",
        "address": "Pilani, Rajasthan",
        "phone": "+91-1596-245073",
        "email": "admissions@pilani.bits-pilani.ac.in",
        "website": "https://www.bits-pilani.ac.in",
        "admission_info": "BITSAT Entrance Exam",
        "exam": "BITSAT",
      },
    ],
    "medical": [
      {
        "name": "AIIMS Delhi",
        "type": "government",
        "country": "India",
        "address": "Ansari Nagar, New Delhi",
        "phone": "+91-11-2658-8500",
        "email": "admin@aiims.edu",
        "website": "https://www.aiims.edu",
        "admission_info": "NEET-UG for MBBS",
        "exam": "NEET-UG",
      },
      {
        "name": "CMC Vellore",
        "type": "private",
        "country": "India",
        "address": "Vellore, Tamil Nadu",
        "phone": "+91-416-228-2016",
        "email": "info@cmcvellore.ac.in",
        "website": "https://www.cmch-vellore.edu",
        "admission_info": "NEET-UG for MBBS",
        "exam": "NEET-UG",
      },
      {
        "name": "JIPMER Puducherry",
        "type": "government",
        "country": "India",
        "address": "Puducherry",
        "phone": "+91-413-227-4000",
        "email": "registrar@jipmer.edu.in",
        "website": "https://jipmer.edu.in",
        "admission_info": "NEET-UG for MBBS",
        "exam": "NEET-UG",
      },
      {
        "name": "AFMC Pune",
        "type": "government",
        "country": "India",
        "address": "Pune, Maharashtra",
        "phone": "+91-20-2633-2222",
        "email": "info@afmc.nic.in",
        "website": "https://afmc.nic.in",
        "admission_info": "NEET-UG + AFMC criteria",
        "exam": "NEET-UG",
      },
    ],
    "law": [
      {
        "name": "NLSIU Bangalore",
        "type": "government",
        "country": "India",
        "address": "Bengaluru, Karnataka",
        "phone": "+91-80-2306-9468",
        "email": "admissions@nls.ac.in",
        "website": "https://www.nls.ac.in",
        "admission_info": "CLAT",
        "exam": "CLAT",
      },
      {
        "name": "NLU Delhi",
        "type": "government",
        "country": "India",
        "address": "Dwarka, New Delhi",
        "phone": "+91-11-2530-2323",
        "email": "info@nludelhi.ac.in",
        "website": "https://nludelhi.ac.in",
        "admission_info": "AILET",
        "exam": "AILET",
      },
      {
        "name": "NALSAR Hyderabad",
        "type": "government",
        "country": "India",
        "address": "Hyderabad, Telangana",
        "phone": "+91-40-2318-8300",
        "email": "registrar@nalsar.ac.in",
        "website": "https://www.nalsar.ac.in",
        "admission_info": "CLAT",
        "exam": "CLAT",
      },
      {
        "name": "NLU Jodhpur",
        "type": "government",
        "country": "India",
        "address": "Jodhpur, Rajasthan",
        "phone": "+91-291-244-8100",
        "email": "info@nlujodhpur.ac.in",
        "website": "https://nlujodhpur.ac.in",
        "admission_info": "CLAT",
        "exam": "CLAT",
      },
    ],
    "commerce": [
      {
        "name": "Shri Ram College of Commerce (SRCC)",
        "type": "government",
        "country": "India",
        "address": "North Campus, Delhi University",
        "phone": "+91-11-2766-2319",
        "email": "principal@srcc.edu",
        "website": "https://www.srcc.edu",
        "admission_info": "CUET UG",
        "exam": "CUET",
      },
      {
        "name": "St. Xavier's College Mumbai",
        "type": "private",
        "country": "India",
        "address": "Mumbai, Maharashtra",
        "phone": "+91-22-2262-0661",
        "email": "info@xaviers.edu",
        "website": "https://xaviers.edu",
        "admission_info": "Entrance + CUET",
        "exam": "CUET / College Test",
      },
      {
        "name": "Loyola College Chennai",
        "type": "private",
        "country": "India",
        "address": "Chennai, Tamil Nadu",
        "phone": "+91-44-2817-8200",
        "email": "info@loyolacollege.edu",
        "website": "https://www.loyolacollege.edu",
        "admission_info": "Merit + CUET",
        "exam": "CUET",
      },
      {
        "name": "Christ University Bangalore",
        "type": "private",
        "country": "India",
        "address": "Bengaluru, Karnataka",
        "phone": "+91-8040129600",
        "email": "admission@christuniversity.in",
        "website": "https://christuniversity.in",
        "admission_info": "Christ Entrance Test",
        "exam": "CUET / CET",
      },
    ],
  };

  /// Get top colleges for an option
  Future<Map<String, dynamic>> getTopColleges({required String option}) async {
    final category = optionToCategory[option];

    if (category == null) {
      return {"top_colleges": [], "source": "mapping_not_found"};
    }

    // ✅ First check static data
    if (_staticData.containsKey(category)) {
      return {"top_colleges": _staticData[category], "source": "static"};
    }

    // ✅ Fallback empty
    return {"top_colleges": [], "source": "not_available"};
  }
}
