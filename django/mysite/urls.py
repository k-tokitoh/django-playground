"""
URL configuration for mysite project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    # それぞれで完結して回遊させるためには、namespaceでインスタンス名前空間を与える必要がある
    path("polls/", include("polls.urls", namespace="original")),
    path("yet-another-polls/", include("polls.urls", namespace="yet-another")),
    # URLパターンをインクルードするときは常に include() を使うべきです。 admin.site.urls はこれについての唯一の例外です。
    # https://docs.djangoproject.com/ja/5.1/intro/tutorial01/
    path("admin/", admin.site.urls),
]
