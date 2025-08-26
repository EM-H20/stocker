// FILE: lib/features/note/presentation/constants/note_templates.dart
/// 노트 작성 시 사용할 수 있는 템플릿 모음
class NoteTemplate {
  final String name; // 템플릿 이름 (예: "재무제표 분석")
  final String content; // Quill 에디터의 Delta(JSON) 형식 데이터

  const NoteTemplate({required this.name, required this.content});
}

class NoteTemplates {
  static const List<NoteTemplate> templates = [
    NoteTemplate(
      name: '빈 노트',
      content: r'[{"insert":"\n"}]', // Quill의 빈 문서 기본값
    ),
    NoteTemplate(
      name: '재무제표 분석',
      content: r'''
      [
        {"insert":"기업명: ","attributes":{"bold":true}},
        {"insert":"\n"},
        {"insert":"분석일: ","attributes":{"bold":true}},
        {"insert":"\n"},
        {"insert":"\n","attributes":{"block":"divider"}},
        {"insert":"\n"},
        {"insert":"1. 매출액 (Revenue)","attributes":{"bold":true}},
        {"insert":" : ","attributes":{"bold":true,"color":"#9e9e9e"}},
        {"insert":"\n"},
        {"insert":"\t- 전기 대비: \n"},
        {"insert":"\t- 전년 대비: \n\n"},
        {"insert":"2. 영업이익 (Operating Income)","attributes":{"bold":true}},
        {"insert":" : ","attributes":{"bold":true,"color":"#9e9e9e"}},
        {"insert":"\n"},
        {"insert":"\t- 전기 대비: \n"},
        {"insert":"\t- 전년 대비: \n\n"},
        {"insert":"3. 순이익 (Net Income)","attributes":{"bold":true}},
        {"insert":" : ","attributes":{"bold":true,"color":"#9e9e9e"}},
        {"insert":"\n"},
        {"insert":"\t- 전기 대비: \n"},
        {"insert":"\t- 전년 대비: \n\n"},
        {"insert":"4. 종합 평가","attributes":{"bold":true}},
        {"insert":"\n"},
        {"insert":"\t- 수익성: ☆☆☆☆☆\n"},
        {"insert":"\t- 안정성: ☆☆☆☆☆\n"},
        {"insert":"\t- 성장성: ☆☆☆☆☆\n\n"},
        {"insert":"메모:","attributes":{"bold":true,"color":"#9e9e9e"}},
        {"insert":"\n"},
        {"insert":"\n","attributes":{"block":"divider"}},
        {"insert":"\n"}
      ]
      ''',
    ),
    NoteTemplate(
      name: '투자 결정서',
      content: r'''
      [
        {"insert":"종목명: ", "attributes":{"bold":true}},
        {"insert":"\n"},
        {"insert":"\n","attributes":{"block":"divider"}},
        {"insert":"\n"},
        {"insert":"1. 가치 평가 (Valuation)", "attributes":{"header":2}},
        {"insert":"\n"},
        {"insert":"현재 주가가 기업의 내재가치에 비해 저평가되어 있다고 생각하는가?"},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"경쟁사 대비 주가수익비율(PER) 등 상대가치가 매력적인가?"},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"\n"},
        {"insert":"2. 성장 잠재력 (Growth Potential)", "attributes":{"header":2}},
        {"insert":"\n"},
        {"insert":"해당 기업이 속한 산업의 전반적인 전망이 긍정적인가?"},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"시장을 선도할 만한 독점적인 기술이나 경쟁 우위(해자)가 있는가?"},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"미래 성장을 위한 신사업 투자나 연구개발(R&D)이 활발한가?"},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"\n"},
        {"insert":"3. 안정성 및 리스크 (Stability & Risk)", "attributes":{"header":2}},
        {"insert":"\n"},
        {"insert":"꾸준한 매출과 이익을 내며, 재무 상태가 건전한가?"},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"부채 비율이 안정적이며, 꾸준한 현금 흐름을 창출하는가?"},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"경영진은 신뢰할 만하며, 주주 친화적인 정책을 펼치고 있는가?"},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"예상치 못한 악재나 규제 등 잠재적인 리스크 요인이 있는가?"},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"\n"},
        {"insert":"4. 시장 심리 (Market Sentiment)", "attributes":{"header":2}},
        {"insert":"\n"},
        {"insert":"최근 주가 흐름이 긍정적인가?"},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"기관 투자자나 외국인 투자자들의 수급이 꾸준히 유입되고 있는가?"},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"해당 종목에 대한 긍정적인 뉴스나 증권사 리포트가 많은 편인가?"},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"\n"},
        {"insert":"최종 투자 의사", "attributes":{"header":2,"bold":true}},
        {"insert":"\n"},
        {"insert":"아래 항목 중 하나만 선택하여 V 체크하세요.", "attributes":{"italic":true,"color":"#757575"}},
        {"insert":"\n"},
        {"insert":"매우 강함"},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"강함"},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"보통"},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"적음"},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"매우 적음"},{"insert":"\n","attributes":{"list":"unchecked"}}
      ]
      ''',
    ),
    NoteTemplate(
      name: '자산 관리',
      content: r'''
      [
        {"insert":"기준 월: ", "attributes":{"bold":true}},
        {"insert":"\n"},
        {"insert":"\n","attributes":{"block":"divider"}},
        {"insert":"\n"},
        {"insert":"1. 자산 현황 (Balance Sheet)", "attributes":{"header":2}},
        {"insert":"\n"},
        {"insert":"\t- 유동 자산 (주식, 예금 등): \n"},
        {"insert":"\t- 부동산: \n"},
        {"insert":"\t- 기타 자산: \n"},
        {"insert":"\t- 부채 (대출 등): \n"},
        {"insert":"\t- 순자산 (총자산 - 총부채): \n\n"},
        {"insert":"2. 월별 현금 흐름 (Cash Flow)", "attributes":{"header":2}},
        {"insert":"\n"},
        {"insert":"\t- 총 수입 (월급, 부수입 등): \n"},
        {"insert":"\t- 총 지출 (고정, 변동 포함): \n"},
        {"insert":"\t- 월 저축액 (총 수입 - 총 지출): \n\n"},
        {"insert":"3. 이달의 목표 및 피드백", "attributes":{"header":2}},
        {"insert":"\n"},
        {"insert":"목표 1: "},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"목표 2: "},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"목표 3: "},{"insert":"\n","attributes":{"list":"unchecked"}},
        {"insert":"\n"},
        {"insert":"이달의 피드백:","attributes":{"italic":true,"color":"#757575"}},
        {"insert":"\n"},
        {"insert":"\n","attributes":{"block":"divider"}},
        {"insert":"\n"}
      ]
      ''',
    ),
  ];
}
