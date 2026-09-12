//
//  HomeView.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

private struct HomeView: View {

    let session: Session

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 24
            ) {
                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {
                    Text("WakTrainer")
                        .font(.largeTitle.bold())

                    Text("오늘도 좋은 훈련 되세요.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {
                    Text("로그인 계정")
                        .font(.headline)

                    Text(session.user.email)
                        .foregroundStyle(.secondary)
                    if !session.user.isEmailVerified {
                        Text("이메일 인증 필요 · 설정에서 인증 메일을 재전송할 수 있습니다.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    .regularMaterial,
                    in: RoundedRectangle(
                        cornerRadius: 16
                    )
                )

                Spacer()
            }
            .padding()
        }
        .navigationTitle("홈")
    }
}
