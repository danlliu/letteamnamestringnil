"""routing URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.2/topics/http/urls/
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
from django.urls import path
from app import views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('user/', views.user, name='user'),
    path('parties/', views.parties, name='parties'),
    path('parties/join/', views.join_party, name='join_party'),
    path('parties/<str:party_code>/', views.party_info, name='party_info'),
    path('parties/<str:party_code>/members/<int:member_id>/', views.member_info, name='member_info'),
    path('parties/<str:party_code>/npcs/', views.party_npcs, name='party_npcs'),
    path('parties/<str:party_code>/npcs/<int:npc_id>/', views.npc_info, name='npc_info'),
    path('parties/<str:party_code>/spells/', views.party_spells, name='party_spells'), 
]
