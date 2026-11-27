sealed class TermsBlock {
  const TermsBlock();
}

class TermsPara extends TermsBlock {
  const TermsPara(this.text);
  final String text;
}

class TermsBullet extends TermsBlock {
  const TermsBullet(this.text, {this.lead});
  final String? lead;
  final String text;
}

class TermsSection {
  const TermsSection(this.title, this.blocks);
  final String title;
  final List<TermsBlock> blocks;
}

abstract final class TermsContent {
  static const title = 'Buahaya Terms of Service';
  static const lastUpdated = 'LAST UPDATED: NOVEMBER 2026';

  static const intro = [
    TermsPara(
        'Welcome to Buahaya. These Terms of Service ("Terms") constitute a legally binding agreement between you ("User", "you") and Buahaya ("Company", "we", "us", or "our") governing your access to and use of the Buahaya mobile application, services, and related software (collectively, the "Service").'),
    TermsPara(
        'By downloading, accessing, installing, or using the Service, you signify that you have read, understood, and agree to be bound by these Terms and our Privacy Policy. If you do not agree to these Terms, please do not access or use the Service.'),
  ];

  static const sections = [
    TermsSection('1. Acceptance of Terms & Eligibility', [
      TermsPara(
          'You must be at least 13 years of age (or the minimum legal age in your jurisdiction) to use Buahaya. By agreeing to these Terms, you represent and warrant that you possess the legal capacity to enter into this contract and that you are not prohibited from using the Service under applicable international or domestic trade laws.'),
    ]),
    TermsSection('2. AI Fruit Freshness Detection Disclaimer', [
      TermsPara(
          'Buahaya integrates machine learning and computer vision algorithms designed to evaluate external visual indicators of fruit ripeness, storage phases, and general condition.'),
      TermsBullet(
          'All assessments, freshness scores, and shelf-life estimates provided by the Service are automated estimates intended solely for general informational convenience.',
          lead: 'Informational Purposes Only: '),
      TermsBullet(
          'The Service does not provide scientific, medical, or microbiological certifications. Computer vision cannot detect internal decay, harmful pathogens, foodborne bacteria, mold spores, or internal chemical contaminants.',
          lead: 'No Health or Safety Guarantee: '),
      TermsBullet(
          'Always exercise standard food safety precautions. Inspect physical produce using aroma, texture, firmness, and natural visual examination prior to preparation or consumption. We assume no liability for foodborne illness or produce spoilage resulting from reliance on the software.',
          lead: 'User Responsibility: '),
    ]),
    TermsSection('3. Shopping Lists & Collaborative Features ("Belanja Bareng")', [
      TermsPara(
          'Buahaya enables synchronized grocery planning and collaborative checklists through its "Belanja Bareng" feature.'),
      TermsBullet(
          'When you invite contributors or share an active list link, invited collaborators may view, check, modify, or delete items within that shared repository.'),
      TermsBullet(
          'You are solely responsible for managing collaborator access permissions and safeguarding the distribution of private invite links.'),
      TermsBullet(
          'We do not guarantee uninterrupted real-time synchronization under poor network connectivity or multi-user merge conflicts.'),
    ]),
    TermsSection('4. User Accounts, Authentication & Security', [
      TermsPara(
          'Certain features require you to maintain a registered account. You agree to provide accurate, current, and complete registration data. You are solely responsible for maintaining the confidentiality of your login credentials and one-time verification passcodes (OTP). You agree to immediately notify us of any unauthorized use or security breach related to your account.'),
    ]),
    TermsSection('5. Camera Permissions & Privacy', [
      TermsPara(
          'Freshness detection requires camera access. Camera video feeds are processed in transient local device memory during active detection sessions.'),
      TermsPara(
          'Buahaya does not record ambient household video streams, store uncompressed raw feeds without explicit user initiation, or monetize your dietary routines to third-party advertising networks. Detailed disclosures regarding personal data handling are set forth in our Privacy Policy.'),
    ]),
    TermsSection('6. Intellectual Property & Prohibited Conduct', [
      TermsPara(
          'We grant you a revocable, non-exclusive, non-transferable, limited personal license to install and use the application on mobile devices that you own or control.'),
      TermsPara('You agree that you will not:'),
      TermsBullet(
          'Reverse engineer, decompile, disassemble, or extract source code from the application or machine learning models;'),
      TermsBullet('Scrape, mine, or harvest data from the Service using automated crawlers, bots, or spiders;'),
      TermsBullet(
          'Resell, lease, sublicense, or commercially exploit the software without prior written authorization.'),
    ]),
    TermsSection('7. Limitation of Liability & Disclaimers of Warranty', [
      TermsPara(
          'THE SERVICE IS PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.'),
      TermsPara(
          'IN NO EVENT SHALL BUAHAYA, ITS DIRECTORS, EMPLOYEES, OR AFFILIATES BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, INCLUDING FOOD WASTAGE, PHYSICAL ILLNESS, PROPERTY DAMAGE, OR LOSS OF DATA, RESULTING FROM YOUR USE OF OR INABILITY TO USE THE SERVICE.'),
    ]),
    TermsSection('8. Termination of Service', [
      TermsPara(
          'We reserve the right to suspend or terminate your account and access to the Service at our sole discretion, without prior notice, if you breach any term of these Terms or engage in fraudulent, harmful, or abusive conduct. You may terminate your agreement at any time by ceasing all use and deleting the application.'),
    ]),
    TermsSection('9. Modifications to Terms', [
      TermsPara(
          'We may amend or update these Terms periodically to reflect changes in our service offerings, technical architecture, or legal requirements. Material revisions will be accompanied by an in-app notice or an updated revision date at the top of this document. Continued use of Buahaya following posted changes constitutes your acceptance of the revised Terms.'),
    ]),
    TermsSection('10. Governing Law & Contact Information', [
      TermsPara(
          'These Terms shall be governed by and interpreted in accordance with applicable laws, without regard to conflict of law principles.'),
      TermsPara('For legal inquiries, feedback, or support regarding these Terms, please contact our support team at:'),
      TermsPara('Email: support@buahaya.app'),
    ]),
  ];
}
