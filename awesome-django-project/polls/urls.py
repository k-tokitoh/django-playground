from django.urls import path

from . import views

# includeでnamespaceを指定してインスタンス名前空間を与えるためには、前提としてapp_nameでアプリケーション名を指定する必要がある
# Specifying a namespace in include() without providing an app_name is not supported.
app_name = "polls"

urlpatterns = [
    # ex: /polls/
    path("", views.IndexView.as_view(), name="index"),
    # ex: /polls/5/
    path("<int:question_id>/", views.detail, name="detail"),
    # ex: /polls/5/results/
    path("<int:pk>/results/", views.ResultsView.as_view(), name="results"),
    # ex: /polls/5/vote/
    path("<int:question_id>/vote/", views.vote, name="vote"),
]
