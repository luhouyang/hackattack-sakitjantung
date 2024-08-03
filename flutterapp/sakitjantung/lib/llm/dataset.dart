import 'package:langchain/langchain.dart';

class Dataset {
  final Map<String, List<Document>> documentsByTopic = {
    'Sumbangan Tunai Rahmah (LHDN)': const [
      Document(
          pageContent:
              "Sumbangan Tunai Rahmah (STR) is a financial assistance program aimed at providing direct cash aid to eligible households in Malaysia. This initiative is designed to alleviate the financial burden on low-income families and support their economic well-being."),
      Document(
          pageContent:
              "Criteria for Deserved Applicants\nEligible applicants for the STR must meet the following criteria:\n1. Malaysian Citizenship: Applicants must be Malaysian citizens.\n2. AgeRequirement: Must be at least 18 years old.\n3. Income Level: The household income must fall below a specified threshold, which is determined annually.\n4. Residency: Applicants must be residents in Malaysia and provide proof of residency.\n5. Household Composition: The household must meet certain criteria regarding the number of dependents"),
      Document(
          pageContent:
              "How to Apply (Step-by-Step) \n1. Visit the Official Website: Go to the STR application portal at bantuantunai.hasil.gov.my. \n2. Register for an Account: If you are a first-time applicant, you will need to create an account by providing your personal information. \n3. Log In: Use your registered credentials to log into the portal. \n4. Fill Out the Application Form: Complete the online application form with accurate details regarding your household, income, and other required information. \n5. Submit Supporting Documents: Upload any necessary documents that verify your identity, income, and residency. \n6. Review Application: Before submitting, review all information to ensure it is correct. \n7. Submit Application: Once everything is in order, submit your application. \n8. Check Application Status: After submission, you can log in to the portal to check the status of your application. \nFor the most accurate and detailed information, including specific income thresholds and deadlines, it is advisable to refer directly to the official website.")
    ],
    'BUDI MADANI': const [
      Document(
          pageContent:
              'The BUDI MySubsidi program offers various forms of financial assistance to different categories of recipients in Malaysia. Here are the details regarding the three types of financial assistance receivers:'),
      Document(
          pageContent:
              "1) BUDI MySubsidi Diesel- Pengangkutan Darat \nThis program is designed for public transport vehicles and selected goods transportation. \nDescription: The Sistem Kawalan Diesel Bersubsidi (SKDS) is a dedicated platform that allows eligible public transport and goods transport vehicles to receive diesel subsidies directly through a 'fleet card.' This initiative aims to reduce operational costs for transport providers and ensure the sustainability of public transport services. \nEligibility: To qualify, applicants must be registered transport operators who utilize diesel fuel for their vehicles. The program helps mitigate the rising costs of diesel, thereby supporting the transport sector."),
      Document(
          pageContent:
              "2) BUDI Agri-Komoditi- Petani dan Pekebun Kecil \nThis assistance targets small-scale farmers and growers. \n Description: Cash subsidies are provided to farmers, livestock breeders, and smallholders registered with the relevant ministries. This financial aid is intended to help these individuals cope with the increased costs of diesel used in agricultural machinery, thereby promoting agricultural productivity and sustainability. \n Eligibility: Applicants must be registered with the appropriate ministry and demonstrate that they are involved in agricultural activities. The program specifically addresses the financial strains caused by rising diesel prices, which are crucial for farming operations."),
      Document(
          pageContent:
              "3) BUDI Individu- Individu (non-T20 individual) \nThis program supports individual diesel vehicle owners. \n Description: Cash subsidies are available for individual diesel vehicle owners who meet specific eligibility criteria. This assistance aims to alleviate the daily transportation costs incurred by individuals using diesel vehicles, particularly in light of rising fuel prices. \n Eligibility: Applicants must be non-T20 individuals, meaning they fall outside the top income bracket. They must demonstrate a genuine need for assistance due to increased transportation costs associated with using diesel vehicles."),
      Document(
          pageContent:
              "Application Process \nFor all categories, the application process typically involves: \n 1. Visit the Official Website: Go to the BUDI MySubsidi portal at budimadani.gov.my. \n 2. Register for an Account: New applicants need to create an account by providing personal details. \n 3. Log In: Use your registered credentials to access the portal. \n 4. Complete the Application Form: Fill out the relevant application form based on your category. \n 5. Submit Supporting Documents: Upload necessary documents that verify your eligibility, such as registration details or proof of income. \n6. Review and Submit Application: Ensure all information is accurate before submitting. \n 7. Check Application Status: After submission, you can log in to monitor the status of your application. \n This structured approach ensures that the assistance reaches those who need it most, supporting various sectors affected by rising diesel costs.")
    ],
    'Bantuan Awal Persekolahan (BAP)': const [
      Document(
          pageContent:
              "Description \nBantuan Awal Persekolahan (BAP) is a one-time cash assistance provided by the Ministry of Education (KPM) to all students to help ease the burden of school expenses borne by parents/guardians in preparing their children for the upcoming school session."),
      Document(
          pageContent:
              "Eligibility\nAll students are eligible to receive BAP, regardless of family income level."),
      Document(
          pageContent:
              "How to Apply \n1. Noapplication is required for most schools. All students are automatically eligible. \n2. The school will determine the payment method for each student, either in cash or credited to their account"),
      Document(
          pageContent:
              "Payment Details \nRM150will be paid to each student in a one-off payment. \nFor newYear 1and Form 1 students, the payment will be made in March 2024. \nFor existing students, the payment will be made starting January 2024.")
    ],
    'Bantuan Awal Ramadhan (BAR)': const [
      Document(
          pageContent:
              "Description \nBantuan Awal Ramadhan (BAR) is a financial assistance program aimed at helping the low-income group prepare for the upcoming Ramadan month."),
      Document(
          pageContent:
              "Eligibility \nHouseholds with a monthly income below RM2,500. \nIndividuals aged 21 and above who are single, widowed, or divorced without children and have a monthly income below RM2,500."),
      Document(
          pageContent:
              "How to Apply \n1. Visit the official BAR website at bar.hasil.gov.my. \n2. Register for an account and provide the required personal and household information. \n3. Submit the application with supporting documents. \n4. Check the application status on the website."),
    ],
    'Sumbangan Asas Rahmah (SARA)': const [
      Document(
          pageContent:
              "Description \nSumbangan Asas Rahmah (SARA) is a targeted financial assistance program aimed at providing basic necessities to the low-income group. "),
      Document(
          pageContent:
              "Eligibility \n Households with a monthly income below RM2,500. \n Individuals aged 21 and above who are single, widowed, or divorced without children and have a monthly income below RM2,500."),
      Document(
          pageContent:
              "How to Apply \n 1. Visit the official SARA website at sara.hasil.gov.my. \n 2. Register for an account and provide the required personal and household information. \n 3. Submit the application with supporting documents. \n 4. Check the application status on the website.")
    ],
    'Bantuan e-Wallet (BINGKAS)': const [
      Document(
          pageContent:
              "Description\nBantuan e-Wallet (BINGKAS) is a financial assistance program that provides e-wallet credits to help the low-income group with daily expenses."),
      Document(
          pageContent:
              "Eligibility\nHouseholds with a monthly income below RM2,500.\nIndividuals aged 21 and above who are single, widowed, or divorced without children and have a monthly income below RM2,500."),
      Document(
          pageContent:
              "How to Apply\n1. Visit the official BINGKAS website at bingkas.hasil.gov.my.\n2. Register for an account and provide the required personal and household information.\n3. Submit the application with supporting documents.\n4. Check the application status on the website."),
    ],
    'Bantuan Khas Penjawat Awam': const [
      Document(
          pageContent:
              "Description\nBantuan Khas Penjawat Awam is a special financial assistance program for civil servants to help with their living expenses."),
      Document(
          pageContent:
              "Eligibility\nAll civil servants are eligible for this assistance."),
      Document(
          pageContent:
              "How to Apply\n1. No application is required. The assistance will be automatically credited to the civil servant's account."),
    ],
    'Bantuan Khas Guru Agama, Imam, Bilal, Siak': const [
      Document(
          pageContent:
              "Description\nThis is a special financial assistance program for religious teachers, imams, bilals, and siaks to help with their living expenses."),
      Document(
          pageContent:
              "Eligibility\nReligious teachers, imams, bilals, and siaks are eligible for this assistance."),
      Document(
          pageContent:
              "How to Apply\n1. No application is required. The assistance will be automatically credited to the eligible individual's account.\nFor the most up-to-date and detailed information on these financial assistance programs, including payment amounts and deadlines, it is advisable to refer directly to the official government websites."),
    ]
  };

  List<String> get topics => documentsByTopic.keys.toList();
}
